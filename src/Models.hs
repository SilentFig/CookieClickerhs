{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE QuasiQuotes #-}


module Models where

import Data.Text (Text)
import Data.Time (UTCTime)
import Database.Persist.TH

-- Template Haskell para gerar as entidades e funções de banco de dados
share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
User json
    username Text
    UniqueUsername username
    email Text
    UniqueEmail email
    passwordHash Text
    cookies Double
    totalCookies Double default=0.0
    cps Double
    equippedMask Int
    activeSkin Int default=0
    createdAt UTCTime default=CURRENT_TIMESTAMP
    deriving Show

Upgrade json
    name Text
    UniqueName name
    description Text
    price Double
    cpsBonus Double
    cpsMultiplier Double default=0.0
    bitValue Int
    UniqueBitValue bitValue
    deriving Show

UserUpgrade json
    userId UserId
    upgradeId UpgradeId
    quantity Int
    UniqueUserUpgrade userId upgradeId
    deriving Show
|]
