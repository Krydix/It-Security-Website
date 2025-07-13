import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: 'IT Security Study Guide',
  tagline: 'Master IT Security & Network Applications',
  favicon: 'img/favicon.ico',

  // Future flags, see https://docusaurus.io/docs/api/docusaurus-config#future
  future: {
    v4: true, // Improve compatibility with the upcoming Docusaurus v4
  },

  // Set the production url of your site here
  url: 'https://krydix.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'Krydix', // Usually your GitHub org/user name.
  projectName: 'It-Security-Website', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Enable Mermaid diagrams
  markdown: {
    mermaid: true,
  },
  themes: ['@docusaurus/theme-mermaid'],

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/Krydix/It-Security-Website/tree/main/',
        },
        // Remove blog configuration - we're using sprint documentation instead
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/docusaurus-social-card.jpg',
    navbar: {
      title: 'IT Security Study Guide',
      logo: {
        alt: 'IT Security Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Study Guide',
        },
        {
          href: 'https://github.com/Krydix/It-Security-Website',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Study Materials',
          items: [
            {
              label: 'Study Guide',
              to: '/docs/intro',
            },
            {
              label: 'Network Security',
              to: '/docs/network-fundamentals',
            },
            {
              label: 'Web Security',
              to: '/docs/web-security-lamp',
            },
          ],
        },
        {
          title: 'Topics',
          items: [
            {
              label: 'Operating Systems',
              to: '/docs/operating-system-security',
            },
            {
              label: 'Cryptography',
              to: '/docs/cryptography-security',
            },
            {
              label: 'Complete Guide',
              to: '/docs/complete-test-guide',
            },
          ],
        },
        {
          title: 'Sprint Documentation',
          items: [
            {
              label: 'Sprint 1 - VM Setup',
              to: '/docs/sprint-documentation/sprint-1',
            },
            {
              label: 'Sprint 2 - Hardening',
              to: '/docs/sprint-documentation/sprint-2',
            },
          ],
        },
        {
          title: 'Deployment',
          items: [
            {
              label: 'Production Setup',
              to: '/docs/production-deployment',
            },
            {
              label: 'Windows Security',
              to: '/docs/windows-security-analysis',
            },
            {
              label: 'GitHub',
              href: 'https://github.com/Krydix/It-Security-Website',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} IT Security Study Guide. Built for educational purposes.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
    mermaid: {
      theme: {
        light: 'neutral',
        dark: 'dark',
      },
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
