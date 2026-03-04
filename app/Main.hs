{-# LANGUAGE OverloadedStrings #-}

import Hakyll

main :: IO ()
main = hakyll $ do
  match "assets/**" $ do
    route   idRoute
    compile copyFileCompiler

  match "css/style.css" $ do
    route   idRoute
    compile copyFileCompiler

  match "templates/*" $ compile templateBodyCompiler

  match "index.md" $ do
    route   $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/default.html" defaultContext
      >>= relativizeUrls
