{-# LANGUAGE OverloadedStrings #-}
module Handlers.InventoryHandler where

import Servant
import Database.Persist.Postgresql
import Models
import Database
import Control.Monad.IO.Class (liftIO)

getInventory :: ConnectionPool -> UserId -> Handler [Entity UserUpgrade]
getInventory pool uid = liftIO $ runDb pool $ selectList [UserUpgradeUserId ==. uid] []

getGame :: ConnectionPool -> UserId -> Handler User
getGame pool uid = do
  mUser <- liftIO $ runDb pool $ get uid
  case mUser of
    Nothing -> throwError err404
    Just u -> return u
