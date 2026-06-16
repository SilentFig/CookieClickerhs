{-# LANGUAGE OverloadedStrings #-}

module Database
  ( makePool
  , doMigrations
  , seedUpgrades
  , runDb
  , ConnectionPool
  ) where

import Control.Monad.Logger (runStdoutLoggingT)
import Database.Persist.Postgresql
import Database.Persist (Filter, (==.))
import Models (migrateAll, Upgrade(..), EntityField(UpgradeName))
import Control.Monad (when)
import System.Environment (lookupEnv)
import Data.Maybe (fromMaybe)
import qualified Data.ByteString.Char8 as BS

-- | Obtém a URL de conexão ao PostgreSQL.
getDatabaseUrl :: IO String
getDatabaseUrl = do
  mUrl <- lookupEnv "DATABASE_URL"

  putStrLn $
    "DATABASE_URL encontrada? " ++
    case mUrl of
      Nothing -> "NAO"
      Just _  -> "SIM"

  pure $ fromMaybe
           "host=localhost dbname=cookieclicker user=postgres password=postgres port=5432"
           mUrl

-- | Cria um pool de conexões com o PostgreSQL
makePool :: IO ConnectionPool
makePool = do
  connStr <- getDatabaseUrl
  runStdoutLoggingT $
    createPostgresqlPool (BS.pack connStr) 10

-- | Aplica automaticamente as migrations geradas pelo Template Haskell no nosso DB.
doMigrations :: ConnectionPool -> IO ()
doMigrations pool = flip runSqlPool pool $ runMigration migrateAll

-- | Helper para executar queries no banco de maneira limpa recebendo o pool.
runDb :: ConnectionPool -> SqlPersistT IO a -> IO a
runDb pool query = runSqlPool query pool

seedUpgrades :: ConnectionPool -> IO ()
seedUpgrades pool = runDb pool $ do
  let upserts =
        [ ("Cursor Auto",     Upgrade "Cursor Auto"     "Clica automaticamente."            15          0.5    0.0  1)
        , ("Vovó",            Upgrade "Vovó"            "Assa cookies deliciosos."          100         4      0.0  2)
        , ("Fazenda",         Upgrade "Fazenda"         "Sementes mágicas."                 1100        32     0.0  4)
        , ("Mina",            Upgrade "Mina"            "Cristais puros de açúcar."         12000       260    0.0  8)
        , ("Receita Secreta", Upgrade "Receita Secreta" "Aumenta seu CPS total em 50%."     50000       0      0.50 16)
        , ("Fábrica",         Upgrade "Fábrica"         "Produção em massa de cookies."     130000      1400   0.0  32)
        , ("Laboratório",     Upgrade "Laboratório"     "Pesquisa avançada de cookies."     1400000     7800   0.0  64)
        , ("Portal",          Upgrade "Portal"          "Importa cookies de outra dimensão." 20000000   44000  0.0  128)
        , ("Máquina do Tempo", Upgrade "Máquina do Tempo" "Busca cookies do futuro."       330000000   260000 0.0  256)
        , ("Antimaterial",    Upgrade "Antimaterial"    "Multiplica seu CPS em 2x."         1000000000  0      1.0  512)
        ]

  mapM_ (\(name, upg) -> do
    c <- count [UpgradeName ==. name]
    when (c == 0) $ insert_ upg
    ) upserts