{-# LANGUAGE OverloadedStrings #-}
module Handlers.UserHandler where

import Servant
import Database.Persist.Postgresql
import Models
import Database
import Control.Monad.IO.Class (liftIO)

getUsers :: ConnectionPool -> Handler [Entity User]
getUsers pool = liftIO $ runDb pool $ selectList [] []

createUser :: ConnectionPool -> User -> Handler UserId
createUser pool user = liftIO $ runDb pool $ insert user

getUser :: ConnectionPool -> UserId -> Handler User
getUser pool uid = do
  mUser <- liftIO $ runDb pool $ get uid
  case mUser of
    Nothing -> throwError err404
    Just u -> return u

updateUser :: ConnectionPool -> UserId -> User -> Handler User
updateUser pool uid user = do
  liftIO $ runDb pool $ replace uid user
  return user

deleteUser :: ConnectionPool -> UserId -> Handler ()
deleteUser pool uid = liftIO $ runDb pool $ do
  deleteWhere [UserUpgradeUserId ==. uid]
  delete uid


loginUser :: ConnectionPool -> User -> Handler (Entity User)
loginUser pool creds = do
  liftIO $ do
    putStrLn $ "LOGIN EMAIL: " ++ show (userEmail creds)
    putStrLn $ "LOGIN SENHA: " ++ show (userPasswordHash creds)

  mUser <- liftIO $ runDb pool $
    selectFirst
      [ UserEmail ==. userEmail creds
      , UserPasswordHash ==. userPasswordHash creds
      ]
      []

  case mUser of
    Nothing -> throwError err401
    Just ent -> return ent