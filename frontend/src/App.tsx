import { useState, useEffect, useCallback } from 'react';
import { Cookie } from './components/Cookie';
import { UpgradePanel } from './components/UpgradePanel';
import { AuthScreen } from './components/AuthScreen';
import { InventoryPanel } from './components/InventoryPanel';
import { ProfileMenu } from './components/ProfileMenu';
import './App.css';

interface Upgrade { id: number; name: string; description: string; price: number; cpsBonus: number; cpsMultiplier: number; bitValue: number; }
interface FloatingText { id: number; x: number; y: number; }
interface InventoryItem { id: number; name: string; quantity: number; equipped: boolean; }
interface User { id: number; username: string; cookies: number; totalCookies: number; cps: number; equippedMask: number; }

function calculateTotalCps(inventory: InventoryItem[], upgrades: Upgrade[]): number {
  let baseCps = 0, multiplier = 1.0;
  inventory.filter(i => i.equipped).forEach(i => {
    const upg = upgrades.find(u => u.id === i.id);
    if(upg) { baseCps += upg.cpsBonus * i.quantity; multiplier += upg.cpsMultiplier * i.quantity; }
  });
  return baseCps * multiplier;
}

const FALLBACK_UPGRADES: Upgrade[] = [
  { id: 1, name: "Cursor Auto", description: "Clica automaticamente.", price: 15, cpsBonus: 0.5, cpsMultiplier: 0, bitValue: 1 },
  { id: 2, name: "Vovó", description: "Assa cookies deliciosos.", price: 100, cpsBonus: 4, cpsMultiplier: 0, bitValue: 2 },
  { id: 3, name: "Fazenda", description: "Sementes mágicas.", price: 1100, cpsBonus: 32, cpsMultiplier: 0, bitValue: 4 },
  { id: 4, name: "Mina", description: "Cristais puros de açucar.", price: 12000, cpsBonus: 260, cpsMultiplier: 0, bitValue: 8 },
  { id: 5, name: "Receita Secreta", description: "Aumenta seu CPS total em 50%.", price: 50000, cpsBonus: 0, cpsMultiplier: 0.50, bitValue: 16 },
  { id: 6, name: "Fábrica", description: "Produção em massa de cookies.", price: 130000, cpsBonus: 1400, cpsMultiplier: 0, bitValue: 32 },
  { id: 7, name: "Laboratório", description: "Pesquisa avançada de cookies.", price: 1400000, cpsBonus: 7800, cpsMultiplier: 0, bitValue: 64 },
  { id: 8, name: "Portal", description: "Importa cookies de outra dimensão.", price: 20000000, cpsBonus: 44000, cpsMultiplier: 0, bitValue: 128 },
  { id: 9, name: "Máquina do Tempo", description: "Busca cookies do futuro.", price: 330000000, cpsBonus: 260000, cpsMultiplier: 0, bitValue: 256 },
  { id: 10, name: "Antimaterial", description: "Multiplica seu CPS em 2x.", price: 1000000000, cpsBonus: 0, cpsMultiplier: 1.0, bitValue: 512 }
];

function App() {
  const [user, setUser] = useState<User | null>(null);
  const [upgrades, setUpgrades] = useState<Upgrade[]>([]);
  const [cookies, setCookies] = useState<number>(0);
  const [totalCookies, setTotalCookies] = useState<number>(0);
  const [cps, setCps] = useState<number>(0);
  const [floatingTexts, setFloatingTexts] = useState<FloatingText[]>([]);
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [milestone, setMilestone] = useState<string | null>(null);
  const [authError, setAuthError] = useState<string | undefined>();
  const [activeSkin, setActiveSkin] = useState<number>(0);
  const [maxUnlockedSkin, setMaxUnlockedSkin] = useState<number>(0);
  const [buyQuantity, setBuyQuantity] = useState<number>(1);
  
  useEffect(() => {
    fetch('/api/upgrades')
      .then(r => r.ok ? r.json() : Promise.reject())
      .then(data => {
         const formatted = data.map((item: any) => ({ ...item, cpsMultiplier: item.cpsMultiplier || 0 }));
         setUpgrades(formatted.length > 0 ? formatted : FALLBACK_UPGRADES);
      }).catch(() => setUpgrades(FALLBACK_UPGRADES));
  }, []);

  const handleLogin = async (username: string, isRegister: boolean) => {
    setAuthError(undefined);
    try {
      const reqBody = { username, email: `${username}@test.com`, passwordHash: "123", cookies: 0, totalCookies: 0, cps: 0, equippedMask: 0, activeSkin: 0, createdAt: new Date().toISOString() };
      if (isRegister) {
        const createRes = await fetch('/api/users', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(reqBody) });
        if (!createRes.ok) throw new Error("Usuário já existe. Tente fazer login.");
        const newId = await createRes.json();
        const getRes = await fetch(`/api/users/${newId}`);
        loginUserToState(await getRes.json());
      } else {
        const res = await fetch('/api/login', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(reqBody) });
        if (!res.ok) throw new Error("Usuário não encontrado.");
        const loginData = await res.json();
        loginUserToState(loginData);
      }
    } catch(e: any) { setAuthError(e.message); }
  };

  const loginUserToState = async (userData: any) => {
    setUser(userData);
    setCookies(userData.cookies);
    setTotalCookies(userData.totalCookies || userData.cookies);
    setCps(userData.cps);
    
    let level = 0;
    const pastCookies = userData.totalCookies || userData.cookies;
    if (pastCookies >= 10000000000) level = 8;
    else if (pastCookies >= 1000000000) level = 7;
    else if (pastCookies >= 100000000) level = 6;
    else if (pastCookies >= 10000000) level = 5;
    else if (pastCookies >= 1000000) level = 4;
    else if (pastCookies >= 100000) level = 3;
    else if (pastCookies >= 10000) level = 2;
    else if (pastCookies >= 1000) level = 1;
    setMaxUnlockedSkin(level);

    const savedSkin = userData.activeSkin !== undefined ? userData.activeSkin : 0;
    setActiveSkin(savedSkin);
    document.body.className = `bg-${savedSkin}`;

    try {
      const invRes = await fetch(`/api/inventory/${userData.id}`);
      const invData = await invRes.json();
      const mergedInventory = upgrades.map(u => {
         const backendInv = invData.find((dbI:any) => dbI.upgradeId === u.id);
         return { id: u.id, name: u.name, quantity: backendInv ? backendInv.quantity : 0, equipped: (userData.equippedMask & u.bitValue) === u.bitValue };
      });
      setInventory(mergedInventory);
    } catch { setInventory(upgrades.map(u => ({ id: u.id, name: u.name, quantity: 0, equipped: false }))); }
  };

  const handleDeleteAccount = async () => {
    if(!user) return;
    try {
      await fetch(`/api/users/${user.id}`, { method: 'DELETE' });
      setUser(null); document.body.className = 'bg-0';
    } catch { alert("Erro ao excluir conta."); }
  };

  useEffect(() => {
    let newMax = 0;
    if (totalCookies >= 10000000000) newMax = 8;
    else if (totalCookies >= 1000000000) newMax = 7;
    else if (totalCookies >= 100000000) newMax = 6;
    else if (totalCookies >= 10000000) newMax = 5;
    else if (totalCookies >= 1000000) newMax = 4;
    else if (totalCookies >= 100000) newMax = 3;
    else if (totalCookies >= 10000) newMax = 2;
    else if (totalCookies >= 1000) newMax = 1;

    if (newMax > maxUnlockedSkin) {
      setMaxUnlockedSkin(newMax);
      const msgs: Record<number, string> = {
        1: '💰 Skin Era de Ouro Desbloqueada!',
        2: '💎 Skin de Cristal Desbloqueada!',
        3: '🌌 Skin Galáctica Desbloqueada!',
        4: '☄️ Skin Cósmica Desbloqueada!',
        5: '🌀 Skin Dimensional Desbloqueada!',
        6: '✨ Skin Divina Desbloqueada!',
        7: '🔥 Skin Infernal Desbloqueada!',
        8: '👁️ Skin do Caos Desbloqueada!'
      };
      setMilestone(msgs[newMax] || '🎉 Nova Skin Desbloqueada!');
      setTimeout(() => setMilestone(null), 4000);
    }
  }, [totalCookies]);

  const equippedCount = inventory.filter(i => i.equipped).length;

  useEffect(() => {
    if (cps === 0 || !user) return;
    const interval = setInterval(() => {
       setCookies(c => c + (cps / 10));
       setTotalCookies(c => c + (cps / 10));
    }, 100);
    return () => clearInterval(interval);
  }, [cps, user]);

  const handleCookieClick = useCallback((x: number, y: number) => {
    const clickPower = 1 + (cps * 0.1);
    setCookies(c => c + clickPower);
    setTotalCookies(c => c + clickPower);
    if(user) fetch(`/api/click/${user.id}`, { method: 'POST' }).catch(()=>null);
    const newText = { id: Date.now() + Math.random(), x, y };
    setFloatingTexts(prev => [...prev, newText]);
    setTimeout(() => setFloatingTexts(prev => prev.filter(t => t.id !== newText.id)), 1000);
  }, [cps, user]);

  const handleBuyUpgrade = async (upgradeId: number, qty: number) => {
    const upgrade = upgrades.find(u => u.id === upgradeId);
    if (upgrade && cookies >= upgrade.price * qty) {
      if(user) {
         const updatedUser = { ...user, cookies: cookies, totalCookies: totalCookies, activeSkin: activeSkin };
         await fetch(`/api/users/${user.id}`, { method: 'PUT', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(updatedUser) }).catch(() => null);
         fetch(`/api/buy-upgrade/${user.id}/${upgradeId}/${qty}`, { method: 'POST' }).catch(()=>null);
      }
      setCookies(c => c - (upgrade.price * qty));
      setInventory(prev => {
        const next = prev.map(item => item.id === upgradeId ? { ...item, quantity: item.quantity + qty } : item);
        setCps(calculateTotalCps(next, upgrades));
        return next;
      });
    }
  };

  const handleEquip = (upgradeId: number) => {
    if(equippedCount >= 2) return;
    setInventory(prev => {
      const next = prev.map(item => item.id === upgradeId ? { ...item, equipped: true } : item);
      setCps(calculateTotalCps(next, upgrades));
      return next;
    });
    if(user && user.id !== 1) fetch(`/api/equip-upgrade/${user.id}/${upgradeId}`, { method: 'POST' }).catch(()=>null);
  };

  const handleUnequip = (upgradeId: number) => {
    setInventory(prev => {
      const next = prev.map(item => item.id === upgradeId ? { ...item, equipped: false } : item);
      setCps(calculateTotalCps(next, upgrades));
      return next;
    });
    if(user && user.id !== 1) fetch(`/api/unequip-upgrade/${user.id}/${upgradeId}`, { method: 'POST' }).catch(()=>null);
  };

  useEffect(() => {
    if (!user) return;
    const handleBeforeUnload = () => {
      const updatedUser = { ...user, cookies: cookies, totalCookies: totalCookies, activeSkin: activeSkin };
      fetch(`/api/users/${user.id}`, { 
         method: 'PUT', 
         headers: {'Content-Type': 'application/json'},
         body: JSON.stringify(updatedUser),
         keepalive: true
      }).catch(() => null);
    };
    window.addEventListener('beforeunload', handleBeforeUnload);
    return () => window.removeEventListener('beforeunload', handleBeforeUnload);
  }, [user, cookies, totalCookies, activeSkin]);

  const handleLogout = async () => {
    if (user) {
      const updatedUser = { ...user, cookies: cookies, totalCookies: totalCookies, activeSkin: activeSkin };
      await fetch(`/api/users/${user.id}`, { 
         method: 'PUT', 
         headers: {'Content-Type': 'application/json'},
         body: JSON.stringify(updatedUser)
      }).catch(() => null);
    }
    setUser(null); 
    document.body.className = 'bg-0';
  };

  if (!user) { return <AuthScreen onLogin={handleLogin} error={authError} />; }

  return (
    <div className="app-container">
      {milestone && <div className="milestone-banner">{milestone}</div>}
      <div className="game-area">
        <ProfileMenu 
          username={user.username} 
          maxUnlockedSkin={maxUnlockedSkin} 
          currentSkin={activeSkin} 
          onSkinChange={(s) => { 
            setActiveSkin(s); 
            document.body.className = `bg-${s}`; 
            if(user) {
              const updatedUser = { ...user, activeSkin: s, cookies: cookies, totalCookies: totalCookies };
              setUser(updatedUser);
              fetch(`/api/users/${user.id}`, { 
                 method: 'PUT', 
                 headers: {'Content-Type': 'application/json'},
                 body: JSON.stringify(updatedUser)
              }).catch(() => null);
            }
          }}
          onLogout={handleLogout}
          onDeleteAccount={handleDeleteAccount}
        />
        <div className="stats-panel">
          <h2 className="cookie-count">{Math.floor(cookies).toLocaleString('pt-BR')}</h2>
          <div className="cps-rate">{cps.toFixed(1)} cookies por segundo</div>
          <div className="historical-total" style={{fontSize: '0.9rem', opacity: 0.8, marginTop: '8px'}}>Histórico: {Math.floor(totalCookies).toLocaleString('pt-BR')} 🍪</div>
        </div>
        <Cookie onClick={handleCookieClick} skinLevel={activeSkin} />
        {floatingTexts.map(text => (
          <div key={text.id} className="floating-number" style={{ left: text.x - 30, top: text.y - 40 }}>
            +{Math.floor(1 + (cps * 0.1))}
          </div>
        ))}
      </div>
      <div className="side-panel">
        <div className="panel-header"><h2>Mercado</h2></div>
        <div className="buy-multiplier" style={{ display: 'flex', justifyContent: 'center', gap: '10px', padding: '10px', background: 'rgba(0,0,0,0.2)', borderBottom: '1px solid rgba(255,255,255,0.1)' }}>
          <span style={{color: '#94a3b8', display: 'flex', alignItems: 'center', fontWeight: 'bold', marginRight: '5px'}}>Comprar:</span>
          <button style={{padding: '4px 10px', borderRadius: '4px', cursor: 'pointer', border: buyQuantity === 1 ? '1px solid #fbbf24' : '1px solid transparent', background: buyQuantity === 1 ? 'rgba(251, 191, 36, 0.2)' : 'transparent', color: buyQuantity === 1 ? '#fbbf24' : '#94a3b8'}} onClick={() => setBuyQuantity(1)}>1x</button>
          <button style={{padding: '4px 10px', borderRadius: '4px', cursor: 'pointer', border: buyQuantity === 10 ? '1px solid #fbbf24' : '1px solid transparent', background: buyQuantity === 10 ? 'rgba(251, 191, 36, 0.2)' : 'transparent', color: buyQuantity === 10 ? '#fbbf24' : '#94a3b8'}} onClick={() => setBuyQuantity(10)}>10x</button>
          <button style={{padding: '4px 10px', borderRadius: '4px', cursor: 'pointer', border: buyQuantity === 100 ? '1px solid #fbbf24' : '1px solid transparent', background: buyQuantity === 100 ? 'rgba(251, 191, 36, 0.2)' : 'transparent', color: buyQuantity === 100 ? '#fbbf24' : '#94a3b8'}} onClick={() => setBuyQuantity(100)}>100x</button>
        </div>
        <div className="upgrades-list"><UpgradePanel upgrades={upgrades} cookies={cookies} buyQuantity={buyQuantity} onBuy={handleBuyUpgrade} /></div>
        <InventoryPanel items={inventory} onEquip={handleEquip} onUnequip={handleUnequip} equippedCount={equippedCount} />
      </div>
    </div>
  );
}
export default App;
