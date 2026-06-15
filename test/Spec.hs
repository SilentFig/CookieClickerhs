import Test.Hspec
import Bitmask

main :: IO ()
main = hspec $ do
  describe "Lógica de Bitmask para Upgrades" $ do
    it "equipa um upgrade (OR)" $ do
      equipUpgrade 0 4 `shouldBe` 4
      equipUpgrade 4 1 `shouldBe` 5
    
    it "desequipa um upgrade (AND COMPLEMENT)" $ do
      unequipUpgrade 5 4 `shouldBe` 1
    
    it "verifica se está equipado (AND)" $ do
      isEquipped 5 4 `shouldBe` True
      isEquipped 5 2 `shouldBe` False

    it "conta o número exato de upgrades equipados (popCount)" $ do
      equippedCount 21 `shouldBe` 3 -- 16 + 4 + 1
    
    it "previne equipar mais de 5 upgrades" $ do
      let mask = 1 + 2 + 4 + 8 + 16
      canEquip mask `shouldBe` False
      canEquip 15 `shouldBe` True -- 8 + 4 + 2 + 1 = 4 upgrades
