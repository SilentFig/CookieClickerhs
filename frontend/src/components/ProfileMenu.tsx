import React, { useState } from 'react';
import './ProfileMenu.css';

interface Props {
  username: string;
  maxUnlockedSkin: number;
  currentSkin: number;
  onSkinChange: (skinId: number) => void;
  onLogout: () => void;
  onDeleteAccount: () => void;
}

export const ProfileMenu: React.FC<Props> = ({ username, maxUnlockedSkin, currentSkin, onSkinChange, onLogout, onDeleteAccount }) => {
  const [open, setOpen] = useState(false);
  
  const skins = [
    { id: 0, name: "Tradicional" },
    { id: 1, name: "Era de Ouro (1k+)" },
    { id: 2, name: "Mina de Cristal (10k+)" },
    { id: 3, name: "Galáctico (100k+)" },
    { id: 4, name: "Cósmico (1M+)" },
    { id: 5, name: "Dimensional (10M+)" },
    { id: 6, name: "Divino (100M+)" },
    { id: 7, name: "Infernal (1B+)" },
    { id: 8, name: "Caos (10B+)" },
  ];

  return (
    <div className="profile-menu-container">
      <div className={`mini-cookie skin-${currentSkin}`} onClick={() => setOpen(!open)}>
         <div className="mc-chip mc-1"></div>
         <div className="mc-chip mc-2"></div>
         <div className="mc-chip mc-3"></div>
      </div>
      
      {open && (
        <div className="profile-dropdown">
          <div className="dropdown-header">
            <strong>{username}</strong>
          </div>
          
          <div className="dropdown-section">
            <label>Mudar Aparência do Cookie:</label>
            <div className="skin-options">
              {skins.map(s => (
                <button 
                  key={s.id}
                  className={`skin-btn ${currentSkin === s.id ? 'active' : ''}`}
                  disabled={s.id > maxUnlockedSkin}
                  onClick={() => { onSkinChange(s.id); setOpen(false); }}
                >
                  {s.name}
                </button>
              ))}
            </div>
          </div>

          <div className="dropdown-actions">
            <button className="dropdown-btn logout" onClick={onLogout}>Sair</button>
            <button className="dropdown-btn delete" onClick={() => {
              if(window.confirm("Certeza que deseja deletar sua conta permanentemente? Todo seu progresso será perdido.")) {
                onDeleteAccount();
              }
            }}>Excluir Conta</button>
          </div>
        </div>
      )}
    </div>
  );
};
