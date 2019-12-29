{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE GADTs #-}
module Pipeline.Eval where

import qualified Data.Text.IO as Text
import Text.Megaparsec

import Grin.Grin
import Grin.TypeCheck
import Grin.Parse
import Grin.Pretty (Pretty)
import Reducer.Base (RTVal)
import qualified Reducer.IO
import qualified Reducer.Pure
import qualified Reducer.LLVM.JIT as LLVM
import qualified Reducer.LLVM.CodeGen as LLVM
import qualified AbstractInterpretation.HeapPointsTo.CodeGen as HPT
import qualified AbstractInterpretation.HeapPointsTo.Result as HPT
import AbstractInterpretation.Reduce (AbstractInterpretationResult(..), evalAbstractProgram)



data Reducer v where
  PureReducer :: Reducer.Pure.ValueConstraints v
              => Reducer.Pure.EvalPlugin v
              -> Reducer v
  IOReducer   :: Reducer Lit

evalProgram :: Reducer v -> Program -> IO (RTVal v)
evalProgram reducer program =
  case reducer of
    PureReducer evalPrimOp  -> Reducer.Pure.reduceFun evalPrimOp program "grinMain"
    IOReducer               -> Reducer.IO.reduceFun program "grinMain"
