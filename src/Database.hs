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

-- | Cria um pool de conexões com o PostgreSQL
-- (Na prática, esses dados de acesso devem vir do ambiente/configuração)
makePool :: IO ConnectionPool
makePool = runStdoutLoggingT $ createPostgresqlPool "host=localhost dbname=cookieclicker user=postgres password=postgres port=5432" 10

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
        , ("Vov\xf3",         Upgrade "Vov\xf3"         "Assa cookies deliciosos."          100         4      0.0  2)
        , ("Fazenda",         Upgrade "Fazenda"         "Sementes m\xe1gicas."               1100        32     0.0  4)
        , ("Mina",            Upgrade "Mina"            "Cristais puros de a\xe7ucar."       12000       260    0.0  8)
        , ("Receita Secreta", Upgrade "Receita Secreta" "Aumenta seu CPS total em 50%."     50000       0      0.50 16)
        , ("F\xe1brica",      Upgrade "F\xe1brica"      "Produ\xe7\xe3o em massa de cookies." 130000      1400   0.0  32)
        , ("Laborat\xf3rio",  Upgrade "Laborat\xf3rio"  "Pesquisa avan\xe7ada de cookies."   1400000     7800   0.0  64)
        , ("Portal",          Upgrade "Portal"          "Importa cookies de outra dimens\xe3o." 20000000 44000  0.0  128)
        , ("M\xe1quina do Tempo", Upgrade "M\xe1quina do Tempo" "Busca cookies do futuro."   330000000   260000 0.0  256)
        , ("Antimaterial",    Upgrade "Antimaterial"    "Multiplica seu CPS em 2x."         1000000000  0      1.0  512)
        ]
  mapM_ (\(name, upg) -> do
    c <- count [UpgradeName ==. name]
    when (c == 0) $ insert_ upg
    ) upserts
