import React from 'react';
import './InventoryPanel.css';

interface InventoryItem {
  id: number;
  name: string;
  quantity: number;
  equipped: boolean;
}

interface Props {
  items: InventoryItem[];
  onEquip: (id: number) => void;
  onUnequip: (id: number) => void;
  equippedCount: number;
}

export const InventoryPanel: React.FC<Props> = ({ items, onEquip, onUnequip, equippedCount }) => {
  const ownedItems = items.filter(item => item.quantity > 0);

  return (
    <div className="inventory-container">
      <div className="inventory-header">
        <h3>Seu Inventário</h3>
        <span className="equip-count">Equipados: {equippedCount}/2</span>
      </div>
      
      {ownedItems.length === 0 ? (
        <p className="empty-inventory">Você ainda não comprou nenhum upgrade.</p>
      ) : (
        <div className="inventory-grid">
          {ownedItems.map(item => (
            <div key={item.id} className={`inventory-card ${item.equipped ? 'equipped' : ''}`}>
              <div className="inv-info">
                <h4>{item.name}</h4>
                <span className="qty">Qtd: {item.quantity}</span>
              </div>
              <button 
                className={`equip-btn ${item.equipped ? 'btn-unequip' : 'btn-equip'}`}
                onClick={() => item.equipped ? onUnequip(item.id) : onEquip(item.id)}
                disabled={!item.equipped && equippedCount >= 2}
              >
                {item.equipped ? 'Desequipar' : 'Equipar'}
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
