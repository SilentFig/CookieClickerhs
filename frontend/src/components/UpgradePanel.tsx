import React from 'react';
import './UpgradePanel.css';

interface Upgrade {
  id: number;
  name: string;
  description: string;
  price: number;
  cpsBonus: number;
  cpsMultiplier: number;
}

interface Props {
  upgrades: Upgrade[];
  cookies: number;
  buyQuantity: number;
  onBuy: (id: number, qty: number) => void;
}

export const UpgradePanel: React.FC<Props> = ({ upgrades, cookies, buyQuantity, onBuy }) => {
  return (
    <div className="upgrade-item-list">
      {upgrades.map(u => {
        const cost = u.price * buyQuantity;
        const canAfford = cookies >= cost;
        return (
          <button 
            key={u.id}
            className={`upgrade-card ${canAfford ? 'affordable' : 'locked'}`}
            onClick={() => canAfford && onBuy(u.id, buyQuantity)}
            disabled={!canAfford}
          >
            <div className="upgrade-info">
              <h3 className="upgrade-name">{u.name}</h3>
              <p className="upgrade-desc">{u.description}</p>
              <div className="upgrade-stats">
                <span className="price">🍪 {Math.floor(cost).toLocaleString('pt-BR')}</span>
                {u.cpsMultiplier > 0 ? (
                  <span className="cps">+{Math.round(u.cpsMultiplier * 100)}% CPS</span>
                ) : (
                  <span className="cps">+{u.cpsBonus} CPS</span>
                )}
              </div>
            </div>
          </button>
        );
      })}
    </div>
  );
};
