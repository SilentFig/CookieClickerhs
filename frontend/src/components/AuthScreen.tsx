import React, { useState } from 'react';
import './AuthScreen.css';

interface Props {
  onLogin: (username: string, password: string, isRegister: boolean) => void;
  error?: string;
}

export const AuthScreen: React.FC<Props> = ({ onLogin, error }) => {
  const [isLogin, setIsLogin] = useState(true);
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (username.trim() && password.trim()) {
      onLogin(username, password, !isLogin);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-box">
        <h1 className="auth-title">Cookie Clicker</h1>
        <p className="auth-subtitle">
          {isLogin ? 'Faça login na sua conta' : 'Crie uma nova conta'}
        </p>

        {error && <div className="auth-error">{error}</div>}

        <form onSubmit={handleSubmit} className="auth-form">
          <input
            type="text"
            placeholder="Nome de Usuário"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            className="auth-input"
            required
          />

          <input
            type="password"
            placeholder="Senha"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="auth-input"
            required
          />

          <button type="submit" className="auth-button">
            {isLogin ? 'Entrar no Jogo' : 'Cadastrar Conta'}
          </button>
        </form>

        <button
          className="auth-switch"
          onClick={() => {
            setIsLogin(!isLogin);
            setUsername('');
            setPassword('');
          }}
        >
          {isLogin
            ? 'Não tem conta? Cadastre-se'
            : 'Já tem conta? Faça Login'}
        </button>
      </div>
    </div>
  );
};