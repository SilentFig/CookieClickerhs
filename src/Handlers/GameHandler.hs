{-# LANGUAGE OverloadedStrings #-}
module Handlers.GameHandler where

import Servant
import Database.Persist.Postgresql
import Models
import Database
import GameLogic
import qualified Bitmask as B
import Control.Monad.IO.Class (liftIO)
import Control.Monad (when)

click :: ConnectionPool -> UserId -> Handler User
click pool uid = do
  mUser <- liftIO $ runDb pool $ get uid
  case mUser of
    Nothing -> throwError err404
    Just u -> do
      let power = clickPower u
          u' = u { userCookies = userCookies u + power, userTotalCookies = userTotalCookies u + power }
      liftIO $ runDb pool $ replace uid u'
      return u'

buyUpgrade :: ConnectionPool -> UserId -> UpgradeId -> Int -> Handler UserUpgrade
buyUpgrade pool uid upId qty = do
  if qty <= 0 then throwError err400 { errBody = "Quantidade inválida" } else return ()
  res <- liftIO $ runDb pool $ do
    mUser <- get uid
    mUp <- get upId
    case (mUser, mUp) of
      (Just u, Just up) -> do
        let cost = upgradePrice up * fromIntegral qty
        if userCookies u >= cost
          then do
            let u' = u { userCookies = userCookies u - cost }
            replace uid u'
            
            mUserUp <- selectFirst [UserUpgradeUserId ==. uid, UserUpgradeUpgradeId ==. upId] []
            finalInv <- case mUserUp of
              Nothing -> do
                let newInv = UserUpgrade uid upId qty
                invId <- insert newInv
                return $ Entity invId newInv
              Just (Entity invId existingInv) -> do
                let updatedInv = existingInv { userUpgradeQuantity = userUpgradeQuantity existingInv + qty }
                replace invId updatedInv
                return $ Entity invId updatedInv
            
            let isEq = B.isEquipped (userEquippedMask u) (upgradeBitValue up)
            when isEq $ do
                allUps <- selectList [] []
                allInvs <- selectList [UserUpgradeUserId ==. uid] []
                let newCps = recomputeCps allUps allInvs (userEquippedMask u)
                update uid [UserCps =. newCps]
            return $ Right (entityVal finalInv)
          else return $ Left err400 { errBody = "Cookies insuficientes" }
      _ -> return $ Left err404
  case res of
    Left e -> throwError e
    Right inv -> return inv

equipUpgrade :: ConnectionPool -> UserId -> UpgradeId -> Handler User
equipUpgrade pool uid upId = do
  res <- liftIO $ runDb pool $ do
    mUser <- get uid
    mUp <- get upId
    mInv <- selectFirst [UserUpgradeUserId ==. uid, UserUpgradeUpgradeId ==. upId] []
    case (mUser, mUp, mInv) of
      (Just u, Just up, Just inv) -> do
        if userUpgradeQuantity (entityVal inv) <= 0
          then return $ Left err400 { errBody = "You do not own this upgrade" }
          else if B.isEquipped (userEquippedMask u) (upgradeBitValue up)
            then return $ Left err400 { errBody = "Already equipped" }
            else if not (B.canEquip (userEquippedMask u))
              then return $ Left err400 { errBody = "Max upgrades equipped" }
              else do
                let newMask = B.equipUpgrade (userEquippedMask u) (upgradeBitValue up)
                allUps <- selectList [] []
                allInvs <- selectList [UserUpgradeUserId ==. uid] []
                let newCps = recomputeCps allUps allInvs newMask
                let u' = u { userEquippedMask = newMask, userCps = newCps }
                replace uid u'
                return $ Right u'
      _ -> return $ Left err404
  case res of
    Left e -> throwError e
    Right u -> return u

unequipUpgrade :: ConnectionPool -> UserId -> UpgradeId -> Handler User
unequipUpgrade pool uid upId = do
  res <- liftIO $ runDb pool $ do
    mUser <- get uid
    mUp <- get upId
    case (mUser, mUp) of
      (Just u, Just up) -> do
        if not (B.isEquipped (userEquippedMask u) (upgradeBitValue up))
          then return $ Left err400 { errBody = "Not equipped" }
          else do
            let newMask = B.unequipUpgrade (userEquippedMask u) (upgradeBitValue up)
            allUps <- selectList [] []
            allInvs <- selectList [UserUpgradeUserId ==. uid] []
            let newCps = recomputeCps allUps allInvs newMask
            let u' = u { userEquippedMask = newMask, userCps = newCps }
            replace uid u'
            return $ Right u'
      _ -> return $ Left err404
  case res of
    Left e -> throwError e
    Right u -> return u
