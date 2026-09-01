import { Toaster } from "@/components/ui/toaster"
import { QueryClientProvider } from '@tanstack/react-query'
import { queryClientInstance } from '@/lib/query-client'
import { BrowserRouter as Router, Route, Routes, Navigate } from 'react-router-dom';
import PageNotFound from './lib/PageNotFound';
import { AuthProvider, useAuth } from '@/lib/AuthContext';
import UserNotRegisteredError from '@/components/UserNotRegisteredError';
import ScrollToTop from './components/ScrollToTop';
import ProtectedRoute from '@/components/ProtectedRoute';

// Auth pages
import Login from '@/pages/Login';
import Register from '@/pages/Register';
import ForgotPassword from '@/pages/ForgotPassword';
import ResetPassword from '@/pages/ResetPassword';

// App pages
import Onboarding from '@/pages/Onboarding';
import Home from '@/pages/Home';
import SafetyMap from '@/pages/SafetyMap';
import SafeRoute from '@/pages/SafeRoute';
import Journey from '@/pages/Journey';
import TrustedCircle from '@/pages/TrustedCircle';
import AddContact from '@/pages/AddContact';
import EmergencyActive from '@/pages/EmergencyActive';
import AIAssistant from '@/pages/AIAssistant';
import FakeCall from '@/pages/FakeCall';
import Profile from '@/pages/Profile';
import Monitor from '@/pages/Monitor';
import EmergencyReport from '@/pages/EmergencyReport';

import AppShell from '@/components/AppShell';

const AuthenticatedApp = () => {
  const { isLoadingAuth, isLoadingPublicSettings, authError, navigateToLogin } = useAuth();

  if (isLoadingPublicSettings || isLoadingAuth) {
    return (
      <div className="fixed inset-0 flex items-center justify-center bg-[hsl(var(--background-deep))]">
        <div className="w-8 h-8 border-4 border-primary/20 border-t-primary rounded-full animate-spin"></div>
      </div>
    );
  }

  if (authError) {
    if (authError.type === 'user_not_registered') {
      return <UserNotRegisteredError />;
    } else if (authError.type === 'auth_required') {
      navigateToLogin();
      return null;
    }
  }

  return (
    <Routes>
      <Route path="/onboarding" element={<Onboarding />} />
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
      <Route path="/forgot-password" element={<ForgotPassword />} />
      <Route path="/reset-password" element={<ResetPassword />} />

      <Route element={<ProtectedRoute unauthenticatedElement={<Navigate to="/login" replace />} />}>
        <Route element={<AppShell />}>
          <Route path="/" element={<Home />} />
          <Route path="/map" element={<SafetyMap />} />
          <Route path="/journey" element={<Journey />} />
          <Route path="/circle" element={<TrustedCircle />} />
          <Route path="/profile" element={<Profile />} />
        </Route>
        <Route path="/route" element={<SafeRoute />} />
        <Route path="/circle/add" element={<AddContact />} />
        <Route path="/assistant" element={<AIAssistant />} />
        <Route path="/fake-call" element={<FakeCall />} />
        <Route path="/emergency" element={<EmergencyActive />} />
        <Route path="/emergency/report/:id" element={<EmergencyReport />} />
        <Route path="/monitor" element={<Monitor />} />
      </Route>

      <Route path="*" element={<PageNotFound />} />
    </Routes>
  );
};

function App() {
  return (
    <AuthProvider>
      <QueryClientProvider client={queryClientInstance}>
        <Router>
          <ScrollToTop />
          <AuthenticatedApp />
        </Router>
        <Toaster />
      </QueryClientProvider>
    </AuthProvider>
  )
}

export default App