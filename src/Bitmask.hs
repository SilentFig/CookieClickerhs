module Bitmask
  ( equipUpgrade
  , unequipUpgrade
  , isEquipped
  , equippedCount
  , canEquip
  ) where

import Data.Bits ((.|.), (.&.), complement, popCount)

-- | Equips an upgrade by applying a bitwise OR.
-- Example: 0 (0000) .|. 4 (0100) = 4 (0100)
equipUpgrade :: Int -> Int -> Int
equipUpgrade currentMask upgradeBitValue = currentMask .|. upgradeBitValue

-- | Unequips an upgrade by applying a bitwise AND with the complement.
-- Example: 21 (10101) .&. complement 4 (11011) = 17 (10001)
unequipUpgrade :: Int -> Int -> Int
unequipUpgrade currentMask upgradeBitValue = currentMask .&. complement upgradeBitValue

-- | Checks if a specific upgrade is equipped by applying a bitwise AND.
-- Example: 21 (10101) .&. 4 (0100) == 4 (0100) (True)
isEquipped :: Int -> Int -> Bool
isEquipped currentMask upgradeBitValue = (currentMask .&. upgradeBitValue) == upgradeBitValue

-- | Returns the total number of equipped upgrades by counting the 1 bits.
equippedCount :: Int -> Int
equippedCount = popCount

-- | Validates if another upgrade can be equipped (max 2 allowed).
canEquip :: Int -> Bool
canEquip currentMask = equippedCount currentMask < 2
