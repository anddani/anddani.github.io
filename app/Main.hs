{-# LANGUAGE OverloadedStrings #-}

import Hakyll

sakeCtx :: Context String
sakeCtx =
     dateField "date" "%B %e, %Y"
  <> defaultContext

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
    compile $ do
      sakes <- recentFirst =<< loadAll "sake/*.md"
      let indexCtx =
            listField "latestSake" sakeCtx (return $ take 2 sakes)
            <> defaultContext
      pandocCompiler
        >>= loadAndApplyTemplate "templates/default.html" indexCtx
        >>= relativizeUrls

  match "sake/*.md" $ do
    route   $ gsubRoute "sake/" (const "sake.log/") `composeRoutes` setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/sake-layout.html" sakeCtx
      >>= relativizeUrls

  create ["sake.log/index.html"] $ do
    route idRoute
    compile $ do
      sakes <- recentFirst =<< loadAll "sake/*.md"
      let listCtx =
            listField "sakes" sakeCtx (return sakes)
            <> constField "title" "sake.log"
            <> defaultContext
      makeItem ""
        >>= loadAndApplyTemplate "templates/sake-list.html" listCtx
        >>= relativizeUrls
