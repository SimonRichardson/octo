package haxez;

import haxez.F1;
import haxez.Monad;
import haxez.T;

enum IdNative<T> {
    Id(x : T);
}

class IdNatives {

    inline public static function fromId<A>(x : AbstractId<A>) : IdNative<A> {
        return IdNative.Id(x.value);
    }

    inline public static function toId<A>(x : IdNative<A>) : AbstractId<A> {
        return switch(x) {
            case Id(a): new AbstractId(a);
        };
    }
}

@:allow(haxez.AbstractId)
private class Z {}

@:allow(haxez.IdNatives.fromId)
class AbstractId<A> implements _1<Z, A> {

    private var value : A;

    public function new(value : A) {
        this.value = value;
    }

    inline public static function monad() : Monad<Z> return new IdOfMonad<Z>();

    public function map<B>(f : F1<A, B>) : AbstractId<B> return new AbstractId(f.apply(value));

    public function flatMap<B>(f : F1<A, AbstractId<B>>) : AbstractId<B> return f.apply(value);

    public function native() : IdNative<A> return IdNative.Id(this.value);
}

abstract Id<A>(AbstractId<A>) from AbstractId<A> to AbstractId<A> {

    inline function new(x : AbstractId<A>) this = x;

    inline public function map<B>(f : F1<A, B>) : Id<B> {
        var x : AbstractId<A> = this;
        return x.map(f);
    }

    inline public function flatMap<B>(f : F1<A, AbstractId<B>>) : Id<B> {
        var x : AbstractId<A> = this;
        return x.flatMap(f);
    }

    @:to
    inline public function toIdNative() : IdNative<A> return IdNatives.fromId(this);

    @:from
    inline public static function fromIdNative<A>(x : IdNative<A>) : Id<A> {
        return IdNatives.toId(x);
    }
}

class IdOfMonad<T> implements Monad<T> {

    public function new() {}

    public function map<A, B>(f : F1<A, B>, fa : _1<T, A>) : _1<T, B> {
        var x : AbstractId<A> = cast fa;
        return cast x.map(f);
    }

    public function point<A>(a : F0<A>) : _1<T, A> {
        return cast new AbstractId(a.apply());
    }

    public function flatMap<A, B>(f : F1<A, _1<T, B>>, fa : _1<T, A>) : _1<T, B> {
        var x : AbstractId<A> = cast fa;
        return cast x.flatMap(new F1Lift(function(a) {
            var y : AbstractId<B> = cast f.apply(a);
            return y;
        }));
    }
}