module Main where

import Control.Monad (forM_, when)
import Data.List (isSuffixOf, isPrefixOf, intercalate)
import System.Directory (doesFileExist, listDirectory)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.FilePath (takeBaseName, takeExtension, (</>))
import System.Process (callProcess)

imgDir :: FilePath
imgDir = "assets/img"

defaultWidth :: String
defaultWidth = "300"

defaultQuality :: String
defaultQuality = "85"

imageExts :: [String]
imageExts = [".jpg", ".jpeg", ".png", ".webp", ".gif", ".JPG"]

isThumbnail :: FilePath -> Bool
isThumbnail f = "_thumbnail" `isSuffixOf` takeBaseName f

isImage :: FilePath -> Bool
isImage f = takeExtension f `elem` imageExts

thumbnailPath :: FilePath -> FilePath -> FilePath
thumbnailPath dir f =
  let base = takeBaseName f
      ext  = takeExtension f
  in dir </> (base ++ "_thumbnail" ++ ext)

data Options = Options
  { optWidth    :: String
  , optForce    :: Bool
  , optCompress :: Bool
  , optQuality  :: String
  , optMaxDim   :: Maybe String
  , optTargets  :: [FilePath]
  }

defaultOptions :: Options
defaultOptions = Options
  { optWidth    = defaultWidth
  , optForce    = False
  , optCompress = False
  , optQuality  = defaultQuality
  , optMaxDim   = Nothing
  , optTargets  = []
  }

main :: IO ()
main = do
  args <- getArgs
  let opts = parseArgs args

  files <- case optTargets opts of
    [] -> do
      entries <- listDirectory imgDir
      let imgs = filter (\f -> isImage f && not (isThumbnail f)) entries
      pure (map (imgDir </>) imgs)
    fs -> pure fs

  when (null files) $
    putStrLn "No images found."

  forM_ files $ \src ->
    if optCompress opts
      then compressImage opts src
      else makeThumbnail opts src

-- | Shrink a copy of the image down to a small preview width.
makeThumbnail :: Options -> FilePath -> IO ()
makeThumbnail opts src = do
  let dest = thumbnailPath imgDir (takeBaseName src ++ takeExtension src)
  exists <- doesFileExist dest
  if exists && not (optForce opts)
    then putStrLn $ "Skipping " ++ src ++ " (thumbnail already exists, use --force to override)"
    else do
      putStrLn $ "Thumbnailing " ++ src ++ " -> " ++ dest
      callProcess "magick"
        [src, "-auto-orient", "-resize", optWidth opts ++ "x>", "-strip", dest]

-- | Re-encode the image in place at a lower JPEG quality (and optionally
-- capped to a maximum dimension) to shrink the file that ships with the site.
compressImage :: Options -> FilePath -> IO ()
compressImage opts src = do
  let resizeArgs = case optMaxDim opts of
        Nothing -> []
        Just d  -> ["-resize", d ++ "x" ++ d ++ ">"]
      capNote = maybe "" (\d -> ", max " ++ d ++ "px") (optMaxDim opts)
  putStrLn $ "Compressing " ++ src ++ " (quality " ++ optQuality opts ++ capNote ++ ")"
  callProcess "magick" $
    [src, "-auto-orient"] ++ resizeArgs ++
    ["-strip", "-interlace", "Plane", "-quality", optQuality opts, src]

parseArgs :: [String] -> Options
parseArgs = go defaultOptions
  where
    go o ("--width"   : n : rest) = go (o { optWidth = n })       rest
    go o ("--force"       : rest) = go (o { optForce = True })    rest
    go o ("--compress"    : rest) = go (o { optCompress = True }) rest
    go o ("--quality" : n : rest) = go (o { optQuality = n })     rest
    go o ("--max-dim" : n : rest) = go (o { optMaxDim = Just n }) rest
    go o (f               : rest) = go (o { optTargets = optTargets o ++ [f] }) rest
    go o []                       = o
