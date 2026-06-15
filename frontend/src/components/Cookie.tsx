import React from 'react';
import './Cookie.css';

interface Props {
  onClick: (x: number, y: number) => void;
  skinLevel: number;
}

export const Cookie: React.FC<Props> = ({ onClick, skinLevel }) => {
  const handleClick = (e: React.MouseEvent<HTMLDivElement>) => {
    onClick(e.clientX, e.clientY);
  };

  return (
    <div className={`cookie-container skin-${skinLevel}`} onMouseDown={handleClick}>
      <div className="main-cookie">
        <div className="chocolate-chip chip-1"></div>
        <div className="chocolate-chip chip-2"></div>
        <div className="chocolate-chip chip-3"></div>
        <div className="chocolate-chip chip-4"></div>
        <div className="chocolate-chip chip-5"></div>
        <div className="chocolate-chip chip-6"></div>
        <div className="chocolate-chip chip-7"></div>
        {skinLevel >= 2 && <div className="glow-effect"></div>}
      </div>
    </div>
  );
};
