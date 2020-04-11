{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

import           LoadEnv                              (loadEnv)
import           Network.Wai                          (Application)
import           Network.Wai.Handler.Warp             (run)
import           Network.Wai.Middleware.RequestLogger (logStdout)
import           Servant
import           Servant.Server                       (Handler, hoistServer)
import           System.Environment                   (getEnv)

import           Config                               (Config (..), getConfig)
import           Control.Monad.Except                 (ExceptT (..))
import           RIO                                  hiding (Handler)
import           Server                               (allApi, getBundleH,
                                                       tedApiView, tedServer)
import           Types


app :: Config -> Application
app config = logStdout $ serve allApi $
  (hoistServer tedApiView nt (tedServer config)) :<|> getBundleH
   where
    nt :: AppM a -> Handler a
    nt (ExceptT foo) =
      Handler $ ExceptT $ runRIO config foo

main :: IO ()
main = do
  loadEnv
  port <- read <$> getEnv "PORT"
  config <- getConfig
  putStrLn $ "Server started at " <> show port
  run port $ app config
