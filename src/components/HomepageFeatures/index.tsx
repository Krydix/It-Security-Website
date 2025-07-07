import type {ReactNode} from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import Link from '@docusaurus/Link';
import styles from './styles.module.css';

type FeatureItem = {
  title: string;
  icon: string;
  description: ReactNode;
  link: string;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Network Security',
    icon: '🌐',
    description: (
      <>
        Master the OSI model, TCP/IP protocols, DNS security, and network fundamentals.
        Learn about encryption layers, port security, and network attack vectors.
      </>
    ),
    link: '/docs/network-fundamentals',
  },
  {
    title: 'Operating System Security',
    icon: '💻',
    description: (
      <>
        Understand UNIX/Linux security architecture, file permissions, SELinux,
        and system-level security mechanisms for robust system protection.
      </>
    ),
    link: '/docs/operating-system-security',
  },
  {
    title: 'Web Application Security',
    icon: '🔒',
    description: (
      <>
        Learn about the CIA triad, LAMP stack security, SQL injection prevention,
        XSS protection, and secure web development practices.
      </>
    ),
    link: '/docs/web-security-lamp',
  },
  {
    title: 'Cryptography & PKI',
    icon: '🔐',
    description: (
      <>
        Explore symmetric and asymmetric encryption, TLS/SSL, digital signatures,
        PKI infrastructure, and cryptographic best practices.
      </>
    ),
    link: '/docs/cryptography-security',
  },
  {
    title: 'Visual Learning',
    icon: '📊',
    description: (
      <>
        Interactive Mermaid diagrams, flowcharts, and visual representations
        help you understand complex security concepts more effectively.
      </>
    ),
    link: '/docs/intro',
  },
  {
    title: 'Exam Preparation',
    icon: '🎓',
    description: (
      <>
        Comprehensive test preparation with practice questions, quick reference guides,
        and structured study materials for your IT security exam.
      </>
    ),
    link: '/docs/complete-test-guide',
  },
];

function Feature({title, icon, description, link}: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <div className="feature-card">
        <div className="feature-icon">{icon}</div>
        <div className="feature-content">
          <Heading as="h3" className="feature-title">{title}</Heading>
          <p className="feature-description">{description}</p>
          <Link
            className="button button--primary button--sm"
            to={link}>
            Learn More →
          </Link>
        </div>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="text--center margin-bottom--lg">
          <Heading as="h2">Master IT Security Concepts</Heading>
          <p className="hero__subtitle">
            Comprehensive study materials with visual diagrams and practical examples
          </p>
        </div>
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
