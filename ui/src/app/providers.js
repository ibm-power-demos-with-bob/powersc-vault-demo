'use client';

import DemoHeader from '../components/Header/Header';
import { Content, Theme } from '@carbon/react';

export function Providers({ children }) {
  return (
    <div>
      <Theme theme="g100">
        <DemoHeader />
      </Theme>
      <Content>{children}</Content>
    </div>
  );
}
