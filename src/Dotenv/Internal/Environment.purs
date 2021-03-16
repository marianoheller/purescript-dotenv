-- | This module encapsulates the logic for reading or modifying the environment.
module Dotenv.Internal.Environment
  ( EnvironmentF(..)
  , _environment
  , handleEnvironment
  , lookupEnv
  , setEnv
  ) where

import Prelude
import Data.Maybe (Maybe)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Node.Process (lookupEnv, setEnv) as P
import Run (Run, lift)
import Type.Proxy (Proxy(..))

-- | A data type representing the supported operations.
data EnvironmentF a
  = LookupEnv String (Maybe String -> a)
  | SetEnv String String a

derive instance functorEnvironmentF :: Functor EnvironmentF

-- The effect label used for reading or modifying the environment.
_environment = Proxy :: Proxy "environment"

-- | The default interpreter used for reading or modifying the environment
handleEnvironment :: EnvironmentF ~> Aff
handleEnvironment op =
  liftEffect
    $ case op of
        LookupEnv name callback -> do
          value <- P.lookupEnv name
          pure $ callback value
        SetEnv name value next -> do
          P.setEnv name value
          pure next

-- | Constructs the value used to look up an environment variable.
lookupEnv :: forall r. String -> Run ( environment :: EnvironmentF | r ) (Maybe String)
lookupEnv name = lift _environment (LookupEnv name identity)

-- | Constructs the value used to set an environment variable.
setEnv :: forall r. String -> String -> Run ( environment :: EnvironmentF | r ) Unit
setEnv name value = lift _environment (SetEnv name value unit)
