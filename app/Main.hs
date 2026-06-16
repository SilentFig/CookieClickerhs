module Main where

import Network.Wai.Handler.Warp
import Database
import Server
import System.Environment (lookupEnv)

main :: IO ()
main = do
  putStrLn "Iniciando backend do Cookie Clicker..."

  pool <- makePool

  putStrLn "Executando migrations do banco de dados..."
  doMigrations pool

  putStrLn "Semeando Upgrades padrão..."
  seedUpgrades pool

  mPort <- lookupEnv "PORT"
  let port = maybe 8081 read mPort

  putStrLn $ "Servidor rodando na porta " ++ show port

  run port (app pool)