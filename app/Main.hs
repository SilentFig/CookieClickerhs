module Main where

import Network.Wai.Handler.Warp
import Database
import Server

main :: IO ()
main = do
  putStrLn "Iniciando backend do Cookie Clicker..."
  pool <- makePool
  putStrLn "Executando migrations do banco de dados..."
  doMigrations pool
  putStrLn "Semeando Upgrades padrão..."
  seedUpgrades pool
  putStrLn "Servidor rodando na porta 8081. Pressione Ctrl+C para encerrar."
  run 8081 (app pool)
