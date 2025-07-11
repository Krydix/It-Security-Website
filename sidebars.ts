import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */
const sidebars: SidebarsConfig = {
  // Main tutorial sidebar with all study materials
  tutorialSidebar: [
    'intro',
    'complete-test-guide',
    'network-fundamentals',
    'operating-system-security',
    'web-security-lamp',
    'cryptography-security',
    'windows-security-analysis',
    {
      type: 'category',
      label: 'Sprint Documentation',
      items: [
        'sprint-documentation/sprint-1',
        'sprint-documentation/sprint-2',
      ],
    },
    'production-deployment',
  ],

  // But you can create a sidebar manually
  /*
  tutorialSidebar: [
    'intro',
    'hello',
    {
      type: 'category',
      label: 'Tutorial',
      items: ['tutorial-basics/create-a-document'],
    },
  ],
   */
};

export default sidebars;
