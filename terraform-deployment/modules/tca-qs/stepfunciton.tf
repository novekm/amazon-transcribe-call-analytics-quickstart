# // TODO - Add state for writing to DynamoDB
resource "random_uuid" "tca_file_uuid" {
}

resource "aws_sfn_state_machine" "tca_sfn_state_machine" {
  name     = var.tca_sfn_state_machine_name
  role_arn = aws_iam_role.tca_step_functions_master_restricted_access[0].arn
  definition = jsonencode({
    Comment = "A State Machine that processes files with Amazon Transcribe Call Analytics"
    StartAt = var.tca_sfn_state_generate_uuid_name
    States = merge(
      # - Generate UUID -
      # Generates a UUID from S3 PutObject id
      {
        # (var.tca_sfn_state_generate_uuid_name) = {
        "${var.tca_sfn_state_generate_uuid_name}" = {
          Type = "Pass",
          Result = {
            "uuid.$" = "$.id"
          }
          ResultPath = "$.taskresult"
          Next       = var.tca_sfn_state_generate_uuid_next_step
        }
      },

      # - StartCallAnalyticsJob -
      # Starts an Amazon Transcribe Call Analytics Job with the file copied to tca_input_bucket
      {
        # (var.tca_sfn_state_start_call_analytics_job_name) = {
        "${var.tca_sfn_state_start_call_analytics_job_name}" = {
          Type     = "Task",
          Resource = "arn:aws:states:::aws-sdk:transcribe:startCallAnalyticsJob",
          Comment  = "Starts an Amazon Transcribe Call Analytics Job with the file copied to tca_input_bucket"

          Parameters = merge(
            {
              "CallAnalyticsJobName.$" = "States.Format('{}-{}',$.detail.object.key, $.id)",
            },
            {
              # (common attributes here)
              ChannelDefinitions = [
                {
                  ChannelId       = 0, // first person to speak in the call
                  ParticipantRole = var.tca_first_speaker_participant_role
                },
                {
                  ChannelId       = 1, // next person to speak in the call
                  ParticipantRole = var.tca_second_speaker_participant_role
                }
              ]
            },
            {
              "OutputLocation.$" = "States.Format('s3://${aws_s3_bucket.tca_output_bucket.id}/{}-{}/{}-{}-transcript.json' ,$.detail.object.key ,$.id ,$.detail.object.key, $.id)"
            },
            {
              Settings = merge(
                {
                  # (common attributes here)
                  LanguageOptions = var.tca_language_options
                },
                # Content Redaction
                coalesce(var.tca_enable_content_redaction ? {
                  # (conditional attributes here)
                  ContentRedaction = {
                    RedactionType   = "PII"
                    RedactionOutput = var.tca_use_redaction_type_redacted_and_unredacted ? "redacted_and_unredacted" : "redacted"
                    PiiEntityTypes  = var.tca_pii_entity_types
                  }
                } : null, {}),

                # Custom Vocabulary
                coalesce(var.tca_use_custom_vocabulary ? {
                  # (conditional attributes here)
                  VocabularyName = var.tca_custom_vocabulary_name
                } : null, {}),
                coalesce(var.tca_use_custom_vocabulary_filter ? {
                  # (conditional attributes here)
                  VocabularyFilterName = var.tca_custom_vocabulary_filter_name
                } : null, {}),

                # Custom Language Model
                coalesce(var.tca_use_custom_language_model ? {
                  # (conditional attributes here)
                  LanguageModelName = var.tca_custom_language_model_name
                } : null, {}),

                # Language ID Settings
                coalesce(var.tca_use_language_id_settings ? {
                  # (conditional attributes here)
                  LanguageIdSettings = {
                    VocabularyName       = var.tca_use_custom_vocabulary ? var.tca_custom_vocabulary_name : null
                    VocabularyFilterName = var.tca_use_custom_vocabulary_filter ? var.tca_custom_vocabulary_filter_name : null
                    LanguageModelName    = var.tca_use_custom_language_model ? var.tca_custom_language_model_name : null

                  }
                } : null, {}),
              )
            },

            # Enable Content Redaction = FALSE
            coalesce(!(var.tca_enable_content_redaction) ? {
              # (conditional attributes here)
              Media = {
                "MediaFileUri.$" = "States.Format('s3://${aws_s3_bucket.tca_input_bucket.id}/{}-{}',$.detail.object.key, $.id)"
              }

            } : null, {}),
            # Enable Content Redaction = TRUE
            coalesce((var.tca_enable_content_redaction) ? {
              # (conditional attributes here)

              Media = {
                "RedactedMediaFileUri.$" = "States.Format('s3://${aws_s3_bucket.tca_input_bucket.id}/{}-{}',$.detail.object.key, $.id)"
              }
            } : null, {}),
          )

          Next = "Wait20Seconds"
        },
      },

      # - Wait 20 Seconds -
      {
        Wait20Seconds = {
          Type    = "Wait",
          Seconds = 20,
          Next    = "GetTCAJobStatus"
        }
      },

      # - GetTCAJobStatus -
      {
        GetTCAJobStatus = {
          Type     = "Task",
          Resource = "arn:aws:states:::aws-sdk:transcribe:getCallAnalyticsJob"
          Comment  = "This is part of the polling loop that gets the TCA job nam to be used with the choice state"
          Parameters = {
            "CallAnalyticsJobName.$" = "$.CallAnalyticsJob.CallAnalyticsJobName"
          }
          Next = "IsTCAJobDone?"
        }
      },

      # - CIsTCAJobDone? -
      {
        "IsTCAJobDone?" = {
          Type = "Choice",
          Choices = [
            {
              Variable     = "$.CallAnalyticsJob.CallAnalyticsJobStatus",
              StringEquals = "COMPLETED"
              Comment      = "Yes - COMPLETED"
              Next         = "CopyToAppStorage"
            },
            {
              Variable     = "$.CallAnalyticsJob.CallAnalyticsJobStatus",
              StringEquals = "QUEUED"
              Comment      = "No - QUEUED"
              Next         = "Wait20Seconds"
            },
            {
              Variable     = "$.CallAnalyticsJob.CallAnalyticsJobStatus",
              StringEquals = "IN_PROGRESS"
              Comment      = "No - IN_PROGRESS"
              Next         = "Wait20Seconds"
            },
            {
              Variable     = "$.CallAnalyticsJob.CallAnalyticsJobStatus",
              StringEquals = "FAILED"
              Comment      = "Yes - FAILED"
              Next         = "TCAFailSNS"
            },

          ]
        }
      },

      # - CopyToAppStorage -
      {
        CopyToAppStorage = {
          Type       = "Task",
          Resource   = "arn:aws:states:::aws-sdk:s3:copyObject",
          ResultPath = "$.getTCAJobOutput"
          Parameters = {
            Bucket         = "${aws_s3_bucket.tca_app_storage_bucket.id}",
            "Key.$"        = "States.Format('{}/{}',$.CallAnalyticsJob.CallAnalyticsJobName ,$.CallAnalyticsJob.CallAnalyticsJobName)", // reference object key from InputPath and add uuid
            "CopySource.$" = "States.Format('${aws_s3_bucket.tca_input_bucket.id}/{}',$.CallAnalyticsJob.CallAnalyticsJobName)"         // reference bucket name and object path from InputPath
          },
          Next = "GetTCAMetadata"
        }
      },

      # - GetTCAMetadata -
      {
        GetTCAMetadata = {
          Type       = "Task",
          Resource   = "arn:aws:states:::aws-sdk:s3:getObject"
          Comment    = "Fetch the TCA job JSON file"
          ResultPath = "$.getTCAJobMetadata"
          Parameters = {
            "Bucket" = "${aws_s3_bucket.tca_output_bucket.id}"
            "Key.$"  = "States.Format('{}/{}-transcript.json',$.CallAnalyticsJob.CallAnalyticsJobName ,$.CallAnalyticsJob.CallAnalyticsJobName)"
          }
          # Next = "Success"
          Next = "PrepareTCAMetadata"
        }
      },


      # - PrepareTCAMetadata -
      {
        PrepareTCAMetadata = {
          Type = "Pass",
          Parameters = {
            ResultSelector = {
              "fileMetadata.$" = "$.CallAnalyticsJob",
              "fileContent.$"  = "States.StringToJson($.getTCAJobMetadata.Body)",
            }
          }
          Next = "WriteToDynamoDB"
        }
      },

      # - WriteToDynamoDB -
      {
        WriteToDynamoDB = {
          Type       = "Task",
          Resource   = "arn:aws:states:::aws-sdk:dynamodb:putItem"
          Comment    = "Write the TCA metadata to DynamoDB"
          ResultPath = "$.DynamoDB"
          Parameters = {
            TableName = "${aws_dynamodb_table.tca_output.id}"
            Item = {
              # Column = {
              #   S = "JobName"
              # }
              JobName = {
                "S.$" = "$.ResultSelector.fileContent.JobName"
              },
              JobStatus = {
                "S.$" = "$.ResultSelector.fileContent.JobStatus"
              },
              LanguageCode = {
                "S.$" = "$.ResultSelector.fileContent.LanguageCode"
              },
              Transcript = {
                "S.$" = "$.ResultSelector.fileContent.Transcript"
              },
              AccountId = {
                "S.$" = "$.ResultSelector.fileContent.AccountId"
              },
              Categories = {
                "S.$" = "$.ResultSelector.fileContent.Categories"
              },
              Channel = {
                "S.$" = "$.ResultSelector.fileContent.Channel"
              },
              Participants = {
                "S.$" = "$.ResultSelector.fileContent.Participants"
              },
              ConversationCharacteristics = {
                "S.$" = "$.ResultSelector.fileContent.ConversationCharacteristics"
              },
              ContentMetadata = {
                "S.$" = "$.ResultSelector.fileContent.ContentMetadata"
              },

              # -- New parameters --
              FilePath = {
                "S.$" = "$.ResultSelector.fileMetadata.Media.MediaFileUri"
              },
              MediaFormat = {
                "S.$" = "$.ResultSelector.fileMetadata.MediaFormat"
              },
              SampleRate = {
                "S.$" = "States.JsonToString($.ResultSelector.fileMetadata.MediaSampleRateHertz)"
              },
              CreatedAt = {
                "S.$" = "$.ResultSelector.fileMetadata.CreationTime"
              },
              CompletedAt = {
                "S.$" = "$.ResultSelector.fileMetadata.CompletionTime"
              },
            }
          }
          Next = "Success"
        }
      },


      # - TCAFailSNS -
      {
        TCAFailSNS = {
          Type     = "Task",
          Resource = "arn:aws:states:::aws-sdk:sns:publish"
          # Resource = "arn:aws:states:::sns:publish"
          Comment = "This is part of the polling loop that gets the TCA job nam to be used with the choice state"
          Parameters = {
            # "Message.$" = "$"
            Message  = "The TCA Step Function has failed. Please check the logs and try to re-upload your media."
            TopicArn = "${aws_sns_topic.tca_sfn_status.arn}"
          }
          Next = "Fail"
        }
      },


      # - Success End State -
      {
        Success = {
          Type = "Succeed"
        },

      },

      # # - Fail End State -
      {
        Fail = {
          Type = "Fail"
        },

      },

      coalesce((var.create_tca_sfn_state_get_tca_input_file) ? {
        # (var.tca_sfn_state_get_tca_input_file_name) = {
        "${var.tca_sfn_state_get_tca_input_file_name}" = {
          Type       = "Task",
          Resource   = "arn:aws:states:::aws-sdk:s3:copyObject",
          ResultPath = "$.getTCAInputStateOutput"
          Parameters = {
            Bucket         = "${aws_s3_bucket.tca_input_bucket.id}",
            "Key.$"        = "States.Format('{}-{}',$.detail.object.key, $.id)",               // reference object key from InputPath and add uuid
            "CopySource.$" = "States.Format('{}/{}',$.detail.bucket.name,$.detail.object.key)" // reference bucket name and object path from InputPath
          },
          Next = "StartCallAnalyticsJob"
        },
      } : null, {}),

      # ---- TEMPLATE FOR OPTIONAL STATE MACHINE STATES ----
      # coalesce(var.condition ? {
      #   # (conditional attributes here)
      # } : null, {}),




    )
  })
}



