{-# LANGUAGE TypeApplications, OverloadedStrings, LambdaCase #-}
module Transformations.Simplifying.VectorisationSpec where

import AbstractInterpretation.AbstractRunGrin
import Transformations.Simplifying.Vectorisation (vectorisation)

import Data.Monoid
import Data.Map
import Test.Hspec
import Free
import Grin

import qualified Data.Map as Map
import qualified Data.Set as Set


spec :: Spec
spec = do
  it "Example from Figure 4.9" $ do
    let hpt = Computer
                mempty
                (Map.singleton "v" (Set.singleton
                  (N (RTNode (tag "Cons" 2)
                      [ Set.singleton (BAS T_I64)
                      , Set.singleton (RTLoc 3)
                      ]))))
                mempty

    before <- buildExpM $
      "l0" <=: store @Int 0                     $
      "v"  <=: unit @Val ("q" @: ["p1", "p2"])  $
      "l1" <=: store @Var "v"                   $
      unit @Int 1

    after <- buildExpM $
      "l0" <=: store @Int 0                                       $
      ("v0" #: ["v1", "v2"]) <=: unit @Val ("q" @: ["p1", "p2"])  $
      "l1" <=: store @Val ("v0" #: ["v1", "v2"])                  $
      unit @Int 1

    vectorisation hpt before `shouldBe` after

runTests :: IO ()
runTests = hspec spec