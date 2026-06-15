module GameLogic where

import Models
import Bitmask
import Database.Persist (Entity(..), entityVal)

-- | Recalcula o CPS total de um usuário baseado nos upgrades equipados e nas quantidades
recomputeCps :: [Entity Upgrade] -> [Entity UserUpgrade] -> Int -> Double
recomputeCps allUpgrades userUpgrades equippedMask =
  let equippedEntities = filter (\(Entity _ u) -> isEquipped equippedMask (upgradeBitValue u)) allUpgrades
      getQty uId = case filter (\(Entity _ inv) -> userUpgradeUpgradeId inv == uId) userUpgrades of
                     (Entity _ inv:_) -> fromIntegral (userUpgradeQuantity inv)
                     [] -> 0
      baseCps = sum $ map (\(Entity k u) -> upgradeCpsBonus u * getQty k) equippedEntities
      multipliers = sum $ map (\(Entity k u) -> upgradeCpsMultiplier u * getQty k) equippedEntities
  in baseCps * (1.0 + multipliers)

-- | Calcula quantos cookies o usuário ganha por clique.
-- Exemplo: 1 base + 10% do seu CPS total
clickPower :: User -> Double
clickPower user = 1.0 + (userCps user * 0.1)
