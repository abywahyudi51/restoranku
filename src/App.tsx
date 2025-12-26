import { useState, useEffect } from 'react';
import CustomerMenu from './components/CustomerMenu';
import AdminDashboard from './components/AdminDashboard';

function App() {
  const [view, setView] = useState<'customer' | 'admin'>('customer');

  useEffect(() => {
    const path = window.location.pathname;
    if (path === '/admin' || path === '/dapur') {
      setView('admin');
    } else {
      setView('customer');
    }
  }, []);

  const toggleView = () => {
    const newView = view === 'customer' ? 'admin' : 'customer';
    setView(newView);
    window.history.pushState({}, '', newView === 'admin' ? '/admin' : '/');
  };

  return (
    <div className="relative">
      {view === 'customer' ? <CustomerMenu /> : <AdminDashboard />}

      <button
        onClick={toggleView}
        className="fixed bottom-4 right-4 bg-gray-800 text-white px-4 py-2 rounded-full shadow-lg hover:bg-gray-700 transition-colors text-sm font-medium z-50"
      >
        {view === 'customer' ? '👨‍🍳 Dapur' : '🍽️ Menu'}
      </button>
    </div>
  );
}

export default App;
