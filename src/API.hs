{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module API where

import Servant
import Database.Persist (Entity)
import Models (User, Upgrade, UserUpgrade, UserId, UpgradeId)

-- | Definição de toda a estrutura da nossa API REST utilizando combinadores do Servant.
type CookieClickerAPI =
  -- Usuários CRUD
       "users" :> Get '[JSON] [Entity User]
  :<|> "users" :> ReqBody '[JSON] User :> Post '[JSON] UserId
  :<|> "users" :> Capture "id" UserId :> Get '[JSON] User
  :<|> "users" :> Capture "id" UserId :> ReqBody '[JSON] User :> Put '[JSON] User
  :<|> "users" :> Capture "id" UserId :> Delete '[JSON] ()
  
  -- Login (Simplificado para o momento)
  :<|> "login" :> ReqBody '[JSON] User :> Post '[JSON] (Entity User)

  -- Upgrades CRUD
  :<|> "upgrades" :> Get '[JSON] [Entity Upgrade]
  :<|> "upgrades" :> ReqBody '[JSON] Upgrade :> Post '[JSON] UpgradeId
  :<|> "upgrades" :> Capture "id" UpgradeId :> Get '[JSON] Upgrade
  :<|> "upgrades" :> Capture "id" UpgradeId :> ReqBody '[JSON] Upgrade :> Put '[JSON] Upgrade
  :<|> "upgrades" :> Capture "id" UpgradeId :> Delete '[JSON] ()

  -- Ações do Jogo
  :<|> "click" :> Capture "userId" UserId :> Post '[JSON] User
  :<|> "buy-upgrade" :> Capture "userId" UserId :> Capture "upgradeId" UpgradeId :> Capture "qty" Int :> Post '[JSON] UserUpgrade
  :<|> "equip-upgrade" :> Capture "userId" UserId :> Capture "upgradeId" UpgradeId :> Post '[JSON] User
  :<|> "unequip-upgrade" :> Capture "userId" UserId :> Capture "upgradeId" UpgradeId :> Post '[JSON] User
  
  -- Consultas de Estado
  :<|> "inventory" :> Capture "userId" UserId :> Get '[JSON] [Entity UserUpgrade]
  :<|> "game" :> Capture "userId" UserId :> Get '[JSON] User

apiProxy :: Proxy CookieClickerAPI
apiProxy = Proxy
