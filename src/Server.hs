module Server where

import Servant
import API
import Database (ConnectionPool)
import Handlers.UserHandler
import Handlers.UpgradeHandler
import Handlers.GameHandler
import Handlers.InventoryHandler
import Network.Wai (Application)
import Network.Wai.Middleware.Cors

server :: ConnectionPool -> Server CookieClickerAPI
server pool =
       getUsers pool
  :<|> createUser pool
  :<|> getUser pool
  :<|> updateUser pool
  :<|> deleteUser pool
  :<|> loginUser pool

  :<|> getUpgrades pool
  :<|> createUpgrade pool
  :<|> getUpgrade pool
  :<|> updateUpgrade pool
  :<|> deleteUpgrade pool

  :<|> click pool
  :<|> buyUpgrade pool
  :<|> equipUpgrade pool
  :<|> unequipUpgrade pool

  :<|> getInventory pool
  :<|> getGame pool

app :: ConnectionPool -> Application
app pool =
  simpleCors $
    serve apiProxy (server pool)