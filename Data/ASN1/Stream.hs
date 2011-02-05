module Data.ASN1.Stream
	( ASN1(..)
	, ASN1Repr
	, ASN1ConstructionType(..)
	, getConstructedEnd
	, getConstructedEndRepr
	) where

import Data.ASN1.Raw
import Data.Text.Lazy (Text)
import Data.ByteString (ByteString)
import qualified Data.ByteString.Lazy as L

data ASN1ConstructionType =
	  Sequence
	| Set
	| Container ASN1Class ASN1Tag
	deriving (Show,Eq)

data ASN1 =
	  Boolean Bool
	| IntVal Integer
	| BitString Int L.ByteString
	| OctetString L.ByteString
	| Null
	| OID [Integer]
	| Real Double
	| Enumerated
	| UTF8String Text
	| NumericString L.ByteString
	| PrintableString Text
	| T61String L.ByteString
	| VideoTexString L.ByteString
	| IA5String Text
	| UTCTime (Int, Int, Int, Int, Int, Int, Bool)
	| GeneralizedTime (Int, Int, Int, Int, Int, Int, Bool)
	| GraphicString L.ByteString
	| VisibleString L.ByteString
	| GeneralString L.ByteString
	| UniversalString Text
	| CharacterString L.ByteString
	| BMPString Text
	| Other ASN1Class ASN1Tag ByteString
	| Start ASN1ConstructionType
	| End ASN1ConstructionType
	deriving (Show, Eq)

{- associate a list of asn1 event with an ASN1 type.
 - it's sometimes required to know the exact byte sequence leading to an ASN1 type:
 - eg: cryptographic signature -}
type ASN1Repr = (ASN1, [ASN1Event])

getConstructedEnd :: Int -> [ASN1] -> ([ASN1],[ASN1])
getConstructedEnd _ xs@[]                = (xs, [])
getConstructedEnd i ((x@(Start _)):xs)   = let (yz, zs) = getConstructedEnd (i+1) xs in (x:yz,zs)
getConstructedEnd i ((x@(End _)):xs)
	| i == 0    = ([], xs)
	| otherwise = let (ys, zs) = getConstructedEnd (i-1) xs in (x:ys,zs)
getConstructedEnd i (x:xs)               = let (ys, zs) = getConstructedEnd i xs in (x:ys,zs)

getConstructedEndRepr :: Int -> [ASN1Repr] -> ([ASN1Repr],[ASN1Repr])
getConstructedEndRepr _ xs@[]                 = (xs, [])
getConstructedEndRepr i ((x@(Start _, _)):xs) = let (yz, zs) = getConstructedEndRepr (i+1) xs in (x:yz,zs)
getConstructedEndRepr i ((x@(End _, _)):xs)
	| i == 0    = ([], xs)
	| otherwise = let (ys, zs) = getConstructedEndRepr (i-1) xs in (x:ys,zs)
getConstructedEndRepr i (x:xs)                = let (ys, zs) = getConstructedEndRepr i xs in (x:ys,zs)
