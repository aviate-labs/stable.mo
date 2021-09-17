import Hash "mo:base/Hash";
import Iter "mo:base/Iter";

import HM "../HashMap";

module {
    public class HashMap<K, V>(
        hash  : (K) -> Hash.Hash,
        equal : (K, K) -> Bool,
    ) {
        var m : HM.HashMap<K, V> = HM.empty<K, V>();

        private func update((m_, ov) : (HM.HashMap<K, V>, ?V)) : ?V { m := m_; ov; };

        public func size() : Nat = HM.size(m);

        public func delete(k : K) = ignore remove(k);

        public func remove(k : K) : ?V = update(HM.remove<K, V>(m, k, hash, equal));

        public func get(k : K) : ?V = HM.get(m, k, hash, equal);

        public func put(k : K, v : V) = ignore replace(k, v);

        public func replace(k : K, v : V) : ?V = update(HM.insert(m, k, hash, equal, v));

        public func entries() : Iter.Iter<(K, V)> = HM.entries(m);
    };
};
