module Talk.Sidebar
  ( render
  ) where

import Core.Prelude

import Core.Model (Talk)
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Talk.Types (Action(..), HTML, SelectedLang(..), State)
import Talk.Util as Util

type Video =
  { name :: String
  , bitrate :: String
  , resolution :: String
  }

mkVideo :: String -> String -> String -> Video
mkVideo = { name: _, bitrate: _, resolution: _}

videos :: Array Video
videos =
  [ mkVideo "720p" "1500k" "1280x720"
  , mkVideo "480p" "950k" "854x480"
  , mkVideo "360p" "600k" "640x360"
  , mkVideo "280p" "320k" "512x288"
  ]

titleCls :: String
titleCls = "text-sm font-normal text-grey500"

itemCls :: String
itemCls = "py-1 px-3 text-sm cursor-pointer"

renderVideo :: Talk -> HTML
renderVideo talk =
  HH.div
  [ class_ "w-1/2 lg:w-full"]
  [ HH.h4 [ class_ titleCls]
    [ HH.text "Download Video"]
  , HH.ul [ class_ "py-1 mb-4"] $
    videos <#> \video ->
      HH.li_
      [ HH.a
        [ class_ $ itemCls <> " Link block"
        , HP.href $ Util.mkVideoUrl talk video.bitrate
        , HP.title $ "Resolution: " <> video.resolution
        ]
        [ HH.text video.name ]
      ]
  ]

renderTranscript :: State -> HTML
renderTranscript { talk, selectedLang } =
  HH.div_
  [ HH.h4 [ class_ titleCls]
    [ HH.text "Download Transcript"]
  , HH.ul [ class_ "py-1 mb-4"] $
    ["txt", "srt"] <#> \format ->
      HH.li_
      [ HH.a
        [ class_ $ itemCls <> " Link block uppercase"
        , HP.href $ Util.mkTranscriptDownloadUrl talk selectedLang format
        ]
        [ HH.text format]
      ]
  ]

isLangSelected :: SelectedLang -> String -> Boolean
isLangSelected selected language =
  case selected of
    NoLang -> false
    OneLang lang -> lang == language
    TwoLang lang1 lang2 -> lang1 == language || lang2 == language

renderLanguages :: State -> HTML
renderLanguages { talk, selectedLang } =
  HH.div_
  [ HH.h4 [ class_ titleCls]
    [ HH.text "Select Languages"]
  , HH.ul [ class_ "py-1 mb-4 flex flex-wrap lg:flex-nowrap lg:flex-col"] $
    talk.languages <#> \language ->
      HH.li
      [ class_ $ getCls language.languageCode
      , style "margin-bottom: 2px;"
      , HE.onClick $ Just <<< const (OnClickLang language.languageCode)
      ] $ join
      [ pure $ HH.text language.endonym
      , guard (isLangSelected selectedLang language.languageCode) $>
        HH.span [ class_ "text-lg ml-3"]
        [ HH.text "×" ]
      ]
  ]
  where
  baseCls = itemCls <> " flex items-center justify-between"
  activeCls = baseCls <> " bg-red500 text-white"
  getCls lang = if isLangSelected selectedLang lang then activeCls else baseCls

render :: State -> HTML
render state =
  HH.div
  [ class_ "Sidebar" ]
  [ renderVideo state.talk
  , renderTranscript state
  , renderLanguages state
  , HH.div
    [ class_ "mt-8"]
    [ HH.a
      [ class_ "Link text-grey500"
      , HP.href $ "https://www.ted.com/talks/" <> state.talk.slug
      , HP.rel "nofollow"
      ]
      [ HH.text "🔗 Go to www.ted.com"]
    ]
  ]
