/* eslint-disable react/no-unescaped-entities */
/* eslint-disable react/jsx-props-no-spreading */
/* eslint-disable react/prop-types */
/* eslint-disable import/no-cycle */
/* eslint-disable no-unused-vars */
/* eslint-disable no-undef */
/** **********************************************************************
                            DISCLAIMER

This is just a playground package. It does not comply with best practices
of using Cloudscape Design components. For production code, follow the
integration guidelines:

https://cloudscape.design/patterns/patterns/overview/
*********************************************************************** */
import React, { useState, useEffect } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
// COMPONENT IMPORTS
import {
  Alert,
  Badge,
  BreadcrumbGroup,
  Button,
  Flashbar,
  AppLayout,
  SideNavigation,
  Container,
  Header,
  HelpPanel,
  Grid,
  Box,
  Icon,
  TextContent,
  SpaceBetween,
} from '@cloudscape-design/components';
import TopNavigationHeader from '../../common/components/TopNavigationHeader';
// Common
import { useColumnWidths } from '../../common/resources/useColumnWidths';
import {
  Notifications,
  ExternalLinkItem,
  TableHeader,
} from '../../common/common-components-config';
import Sidebar from '../../common/components/Sidebar';

import { COLUMN_DEFINITIONS } from './TCAJobsTable/table-property-filter-config';

import TCAJobsTable from './TCAJobsTable';
import { resourcesBreadcrumbs } from './breadcrumbs';

// Styles
import '../../common/styles/base.scss';

const TCAJobs = () => {
  const [columnDefinitions, saveWidths] = useColumnWidths(
    'React-TableServerSide-Widths',
    COLUMN_DEFINITIONS
  );
  const [toolsOpen, setToolsOpen] = useState(false);
  return (
    <AppLayout
      navigation={<Sidebar activeHref="/tca-jobs" />}
      // notifications={<Notifications successNotification={false} />}
      breadcrumbs={<Breadcrumbs />} // define these values in /breadcrumbs/index.js
      content={
        <TCAJobsTable
          columnDefinitions={columnDefinitions} // define these values in /TCAJobsTable/table-property-filter-config.jsx
          saveWidths={saveWidths}
          updateTools={() => setToolsOpen(true)}
        />
      }
      contentType="table"
      tools={<ToolsContent />}
      toolsOpen={toolsOpen}
      onToolsChange={({ detail }) => setToolsOpen(detail.open)}
      stickyNotifications
    />
  );
};

export default TCAJobs;

const Content = () => {
  const [columnDefinitions, saveWidths] = useColumnWidths(
    'React-TableServerSide-Widths',
    COLUMN_DEFINITIONS
  );
  const { userId } = useParams();
  return (
    <TCAJobsTable
      columnDefinitions={columnDefinitions} // define these values in /TCAJobsTable/table-property-filter-config.jsx
      saveWidths={saveWidths}
      updateTools={() => setToolsOpen(true)}
    />
  );
};

export const Breadcrumbs = () => (
  <BreadcrumbGroup
    items={resourcesBreadcrumbs}
    expandAriaLabel="Show path"
    ariaLabel="Breadcrumbs"
  />
);

export const FullPageHeader = ({
  resourceName = 'TCA Jobs',
  createButtonText = 'Create TCA Job',
  // createButtonText = 'Upload File',
  ...props
}) => {
  const navigate = useNavigate();
  const isOnlyOneSelected = props.selectedItems.length === 1;

  return (
    <TableHeader
      variant="awsui-h1-sticky"
      title={resourceName}
      actionButtons={
        <SpaceBetween size="xs" direction="horizontal">
          <Button disabled={!isOnlyOneSelected}>View details</Button>
          <Button disabled={!isOnlyOneSelected}>Edit</Button>
          <Button disabled={props.selectedItems.length === 0}>Delete</Button>
          {/* <Button onClick={() => navigate("/data-uploader")} variant="primary">{createButtonText}</Button> */}
          <Button onClick={() => navigate('/data-uploader')} variant="primary">
            {createButtonText}
          </Button>
        </SpaceBetween>
      }
      {...props}
    />
  );
};

export const ToolsContent = () => (
  <HelpPanel
    header={<h2>TCA Jobs</h2>}
    footer={
      <>
        <h3>
          Learn more{' '}
          <span role="img" aria-label="Icon external Link">
            <Icon name="external" />
          </span>
        </h3>
        <ul>
        <li>
            <ExternalLinkItem
              href="https://aws.amazon.com/energy/"
              text="AWS Energy & Utilities"
            />
          </li>
        {/* <li>
            <ExternalLinkItem
              href="https://aws.amazon.com/energy/"
              text="TBD - Amazon TCAQS Blog Post"
            />
          </li> */}
          <li>
            <ExternalLinkItem
              href="https://aws.amazon.com/transcribe/call-analytics/"
              text="Amazon Transcribe Call Analytics Service Page"
            />
          </li>
          <li>
            <ExternalLinkItem
              href="https://aws.amazon.com/transcribe/faqs/?nc=sn&loc=5"
              text="Amazon Transcribe FAQs"
            />
          </li>
          <li>
            <ExternalLinkItem
              href="https://docs.aws.amazon.com/transcribe/latest/dg/custom-language-models.html"
              text="Amazon Transcribe Custom Language Models"
            />
          </li>
          <li>
            <ExternalLinkItem
              href="https://docs.aws.amazon.com/transcribe/latest/dg/custom-vocabulary.html"
              text="Amazon Transcribe Custom Vocabularies"
            />
          </li>
        </ul>
      </>
    }
  >
    <p>
      View your current TCA jobs and related information such as the transcript,
      time file was, created at,conversation characteristics, and more. To drill
      down even further into the details, choose the name of an individual TCA
      Job.
    </p>
  </HelpPanel>
);


// export const InstanceHeader = ({ ...props }) => {
//   const isOnlyOneSelected = props.selectedItems.length === 1;

//   return (
//     <TableHeader
//       {...props}
//       title="Instances"
//       actionButtons={
//         <SpaceBetween size="xs" direction="horizontal">
//           <Button disabled={!isOnlyOneSelected}>View details</Button>
//           <Button disabled={!isOnlyOneSelected}>Edit</Button>
//           <Button disabled={props.selectedItems.length === 0}>Delete</Button>
//           <Button variant="primary">Create instance</Button>
//         </SpaceBetween>
//       }
//     />
//   );
// };

export const TCAJobsTableEmptyState = ({ resourceName }) => {
  const navigate = useNavigate();

  return (
    <Box margin={{ vertical: 'xs' }} textAlign="center" color="inherit">
      <SpaceBetween size="xxs">
        <div>
          <b>No {resourceName}s</b>
          <Box variant="p" color="inherit">
            No {resourceName}s found. Click 'Create {resourceName}' to start the
            pipeline.
          </Box>
        </div>
        <Button onClick={() => navigate('/data-uploader')}>
          Create {resourceName}
        </Button>
      </SpaceBetween>
    </Box>
  );
};
