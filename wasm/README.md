# custom-plotters
Custom plotting on Rust with WASM + plotters.

## Install Toolkit
```
rustup target add wasm32-unknown-unknown
cargo install wasm-pack
```

## Build
```
wasm-pack build --target web
wasm-pack build --target web --release
```

