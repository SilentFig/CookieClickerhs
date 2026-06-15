{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module Paths_cookie_clicker (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where


import qualified Control.Exception as Exception
import qualified Data.List as List
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude


#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir `joinFileName` name)

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath



bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath
bindir     = "/home/silence/Documents/CookieClicker/.stack-work/install/x86_64-linux/9d4d2ef910ba59714903ca69cbce699963b32366e3324bf824e49e3a5eb21bd5/9.4.8/bin"
libdir     = "/home/silence/Documents/CookieClicker/.stack-work/install/x86_64-linux/9d4d2ef910ba59714903ca69cbce699963b32366e3324bf824e49e3a5eb21bd5/9.4.8/lib/x86_64-linux-ghc-9.4.8/cookie-clicker-0.1.0.0-EH35e0SurpBKEbRZwPCs9D"
dynlibdir  = "/home/silence/Documents/CookieClicker/.stack-work/install/x86_64-linux/9d4d2ef910ba59714903ca69cbce699963b32366e3324bf824e49e3a5eb21bd5/9.4.8/lib/x86_64-linux-ghc-9.4.8"
datadir    = "/home/silence/Documents/CookieClicker/.stack-work/install/x86_64-linux/9d4d2ef910ba59714903ca69cbce699963b32366e3324bf824e49e3a5eb21bd5/9.4.8/share/x86_64-linux-ghc-9.4.8/cookie-clicker-0.1.0.0"
libexecdir = "/home/silence/Documents/CookieClicker/.stack-work/install/x86_64-linux/9d4d2ef910ba59714903ca69cbce699963b32366e3324bf824e49e3a5eb21bd5/9.4.8/libexec/x86_64-linux-ghc-9.4.8/cookie-clicker-0.1.0.0"
sysconfdir = "/home/silence/Documents/CookieClicker/.stack-work/install/x86_64-linux/9d4d2ef910ba59714903ca69cbce699963b32366e3324bf824e49e3a5eb21bd5/9.4.8/etc"

getBinDir     = catchIO (getEnv "cookie_clicker_bindir")     (\_ -> return bindir)
getLibDir     = catchIO (getEnv "cookie_clicker_libdir")     (\_ -> return libdir)
getDynLibDir  = catchIO (getEnv "cookie_clicker_dynlibdir")  (\_ -> return dynlibdir)
getDataDir    = catchIO (getEnv "cookie_clicker_datadir")    (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "cookie_clicker_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "cookie_clicker_sysconfdir") (\_ -> return sysconfdir)




joinFileName :: String -> String -> FilePath
joinFileName ""  fname = fname
joinFileName "." fname = fname
joinFileName dir ""    = dir
joinFileName dir fname
  | isPathSeparator (List.last dir) = dir ++ fname
  | otherwise                       = dir ++ pathSeparator : fname

pathSeparator :: Char
pathSeparator = '/'

isPathSeparator :: Char -> Bool
isPathSeparator c = c == '/'
