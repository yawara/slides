---
author: Yawara ISHIDA
title: 関数型言語入門
date: December 18, 2017
---
## 関数型言語とは何か？

プログラムを『関数』として定義したい。

$$ f: A \rightarrow B \overset{\mathrm def}{\Leftrightarrow} f \subset A \times B \land \forall x \in A. \exists! y \in B. (x,y) \in f $$

---

## で？

1. 項書換え系による計算
2. 強力な型システム
3. 高階（Higher-Order）
4. 参照透過性（Referential Transparency）

---

しかし関数型言語の厳密な定義や合意があるわけではない。

* Untyped
  - Lazy-K
  - Unlambda
* 非純粋
  - Lisp
  - OCaml (Objective Caml, MLの派生)
  - Erlang

---

## Haskellを例に解説していこう。

静的に、強い型付で、純粋。

---

### 1. 項書換え系による計算

左辺から右辺への書き換えが計算を意味する。
```Haskell
s x y z = x z ( y z )
k x y = x

-- s k k x ~> k x ( k x ) ~> x
```


「素朴」に定義を書ける。
```Haskell
fib 0 = 0
fib 1 = 1
fib n = fib (n-1) + fib (n-2)
```

---

データ構造の定義とパターンマッチング
```Haskell
data List a = EmptyList | Append a ( List a )
--- [1,2,3] == Append 1 ( Append 2 ( Append 3 EmptyList ))

reverse_impl EmptyList r = r
reverse_impl (Append x xs) r = reverse_impl xs (Append x r)

reverse xs = reverse_impl xs EmptyList
```

ここで `List` は型コンストラクタ、`EmptyList` は定数、   
`Append` は値コンストラクタ。

---

もう少し例を、Listへのmap関数
```Haskell
map f EmptyList = EmptyList
map f (Append x xs) = Append ( f x ) (map f xs)
```

実際のHaskellでは組み込みの `[]`型が存在。

---

### 2. 強力な型システム

Polymorphism（C++におけるtemplate）

```Haskell
k :: p1 -> p2 -> p1
k x y = x
s :: (t1 -> t2 -> t3) -> (t1 -> t2) -> t1 -> t3
s x y z = x z ( y z )

s k k :: p1 -> p1
```

型クラス制約（C++におけるconcept）
```Haskell
fib :: (Eq a, Num a, Num p) => a -> p
```

---

リテラルもPolymorphic
```Haskell
0 :: Num p => p
2 :: Num p => p
```

型クラス
```Haskell
class Num a where
  (+) :: a -> a -> a
  (-) :: a -> a -> a
  (*) :: a -> a -> a
  negate :: a -> a
  abs :: a -> a
  signum :: a -> a
  fromInteger :: Integer -> a
```

---

こういうオーバーロードはできない。

```Haskell
plus:: Integer -> Integer
plus a b = a + b
plus:: Integer -> Integer -> Integer
plus a b c = a + b + c
```


---

## 3. 高階（Higher-Order）

関手（functor）

```Haskell
class Functor ( f :: * -> * ) where
  fmap :: a -> b -> ( f a -> f b )
```

C++における「Functor」は関数族という意味で誤用。

型コンストラクタにも制約が入ってる。

---

関手であれば以下が期待できるが、条件として与えることはできない。

```Haskell
fmap ( f . g ) == ( fmap f ) . ( fmap g )
```

例えば、自然数を意味する型とか無理。

---

モナド！

```Haskell
class Functor f => Applicative ( f :: * -> * ) where
  pure :: a -> f a
  (<*>) :: f ( a -> b ) -> f a -> f b
```

```Haskell
class Applicative m => Monad ( m :: * -> * ) where
  return :: a -> m a
  return = pure
  (>>=) :: m a -> ( a -> m b ) -> m b
  (>>) :: m a -> m b -> m b
  ma >> mb = m >>= \_ -> mb
```

最新のHaskellではMonadにApplicativeの制約が入ってる。

---

ListはMonadである。

```Haskell
instance Monad [] where
  return x = [x]
  xs >>= f = concat ( map f xs )
```

MaybeはMonadである。

```Haskell
data Maybe a = Nothing | Just a
instance Monad Maybe where
  return = Just
  Nothing >>= f = Nothing
  Just x >>= f = f x
```

---

モナドとDo記法（Syntactic Sugar）

```Haskell
x = m >>= ( \a -> ( mc >>= ( \_ -> ( n >>= ( \b -> f a b )))
```

```Haskell
x = m >>= ( \a ->
    mc >>= ( \_ ->
    n >>= ( \b ->
    f a b )))
```

```Haskell
x = do
  a <- m
  mc
  b <- n
  f a b
```

---

## 4. 参照透過性（Referential Transparency）

---

IOモナド

```Haskell
getLine :: IO String
putStrLn :: String -> IO ()
```

`IO a` はa型の値を返すアクションの型。

`IO ()`はC++における`void`型。

---

do記法でみる。

```Haskell
main :: IO ()
main = do
  putStrLn "Type your name!"
  name <- getLine
  putStrLn "Hello, " ++ name
```

---

IOの実態は

```
type IO a = RealWorld -> (a, RealWorld)
```

的な感じらしい。このあたりはまだ勉強不足。

同じく純粋なCleanという言語は1度しか評価されないことが保証された型（一意型）をもつらしい。

---

## 雑感

* 圏論知ってるとHaskellをより楽しめる。
* Type自体をもっとプログラマブルに扱いたい。 $\mathbb{Z} / \mathbb{Z}_p$ とか。
* 定理証明系（Coqとか）やりたい。
* Haskellを実務で使う可能性は今のところない。
