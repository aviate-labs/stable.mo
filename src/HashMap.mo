import Array "mo:base/Array";
import AssocList "mo:base/AssocList";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";

module {
    // Based on "mo:base/HashMap".

    public type HashMap<K, V> = {
        var table : [var AssocList.AssocList<K, V>];
        var size  : Nat;
    };

    public func empty<K, V>() : HashMap<K, V> {
        return {
            var table = [var];
            var size  = 0;
        };
    };

    /// Returns the number of entries in the HashMap.
    public func size<K, V>(
        m : HashMap<K, V>,
    ) : Nat {
        m.size;
    };

    /// Deletes the entry with the key 'k'. Does not do anything if the key does not exist.
    public func delete<K, V>(
        m     : HashMap<K, V>,
        k     : K,
        hash  : (K) -> Hash.Hash,
        equal : (K, K) -> Bool,
    ) {
        ignore remove(m, k, hash, equal);
    };

    /// Removes the entry with the key 'k' and returns the removed value and the new HashMap.
    public func remove<K, V>(
        m     : HashMap<K, V>,
        k     : K, 
        hash  : (K) -> Hash.Hash,
        equal : (K, K) -> Bool,
    ) : (HashMap<K, V>, ?V) {
        let s = m.table.size();
        if (s == 0) return (m, null);

        let n = Nat32.toNat(hash(k)) % s;
        let (kv, ov) = AssocList.replace<K, V>(
            m.table[n], k, equal, null,
        );
        m.table[n] := kv;
        switch(ov){
            case (null) {}; // Nothing was removed.
            case (? _)  { m.size -= 1; };
        };
        (m, ov);
    };

    /// Gets the entry with the key 'k' and returns its associated value.
    public func get<K, V>(
        m     : HashMap<K, V>,
        k     : K,
        hash  : (K) -> Hash.Hash,
        equal : (K, K) -> Bool,
    ) : ?V {
        let s = m.table.size();
        if (0 == s) return null;

        AssocList.find<K, V>(m.table[Nat32.toNat(hash(k)) % s], k, equal);
    };

    /// Replaces the value 'v' at key 'k'.
    public func put<K, V>(
        m     : HashMap<K, V>,
        k     : K,
        hash  : (K) -> Hash.Hash,
        equal : (K, K) -> Bool,
        v     : V,
    ) = ignore replace(m, k, hash, equal, v);

    /// Replaces the value 'v' at key 'k' and returns the previous value stored at 'k'.
    public func replace<K, V>(
        m     : HashMap<K, V>,
        k     : K,
        hash  : (K) -> Hash.Hash,
        equal : (K, K) -> Bool,
        v     : V,
    ) : (HashMap<K, V>, ?V) {
        let s = m.table.size();

        // Recalculate all tables.
        if (s <= m.size) {
            // Double the table size.
            let size = if (m.size == 0) { 1; } else { s * 2; };
            let table_ = Array.init<AssocList.AssocList<K, V>>(size, null);
            for (i in m.table.keys()) {
                var kvs = m.table[i];
                label l loop {
                    switch (kvs) {
                        case (null) { break l; };
                        case (? ((k, v), ks)) {
                            let n = Nat32.toNat(hash(k)) % table_.size();
                            table_[n] := ?((k, v), table_[n]);
                            kvs := ks;
                        };
                    };
                };
            };
            m.table := table_;
        };

        let n = Nat32.toNat(hash(k)) % m.table.size();
        let (kv, ov) = AssocList.replace<K, V>(
            m.table[n], k, equal, ?v,
        );
        m.table[n] := kv;
        switch(ov){
            case (null) {  m.size += 1; };
            case (? _)  {}; // Value was replaced.
        };
        (m, ov);
    };
};
