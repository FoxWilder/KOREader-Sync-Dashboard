import {StrictMode} from 'react';
import {createRoot} from 'react-dom/client';
import App from './App.tsx';
import './index.css';

// Silence the benign ResizeObserver loop error
if (typeof window !== 'undefined') {
  const isResizeObserverError = (msg: string) => {
    return (
      msg.includes('ResizeObserver loop completed with undelivered notifications') ||
      msg.includes('ResizeObserver loop limit exceeded')
    );
  };

  window.addEventListener('error', (e) => {
    if (isResizeObserverError(e.message)) {
      // Hide Vite error overlay if it's just this benign error
      const viteOverlay = document.querySelector('vite-error-overlay');
      if (viteOverlay) {
        (viteOverlay as HTMLElement).style.display = 'none';
      }
      
      // Stop the error from being logged to console or showing in overlay
      e.stopImmediatePropagation();
    }
  });

  window.addEventListener('unhandledrejection', (e) => {
    if (isResizeObserverError(e.reason?.message || '')) {
      e.stopImmediatePropagation();
    }
  });
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
