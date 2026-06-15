{-# LANGUAGE OverloadedStrings #-}
module Handlers.UpgradeHandler where

import Servant
import Database.Persist.Postgresql
import Models
import Database
import Control.Monad.IO.Class (liftIO)

getUpgrades :: ConnectionPool -> Handler [Entity Upgrade]
getUpgrades pool = liftIO $ runDb pool $ selectList [] []

createUpgrade :: ConnectionPool -> Upgrade -> Handler UpgradeId
createUpgrade pool upgrade = liftIO $ runDb pool $ insert upgrade

getUpgrade :: ConnectionPool -> UpgradeId -> Handler Upgrade
getUpgrade pool uid = do
  mUp <- liftIO $ runDb pool $ get uid
  case mUp of
    Nothing -> throwError err404
    Just u -> return u

updateUpgrade :: ConnectionPool -> UpgradeId -> Upgrade -> Handler Upgrade
updateUpgrade pool uid upgrade = do
  liftIO $ runDb pool $ replace uid upgrade
  return upgrade

deleteUpgrade :: ConnectionPool -> UpgradeId -> Handler ()
deleteUpgrade pool uid = liftIO $ runDb pool $ delete uid
