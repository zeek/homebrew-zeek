class Spicy < Formula
  desc "C++ parser generator for dissecting protocols & files"
  homepage "https://github.com/zeek/spicy"
  url "https://github.com/zeek/spicy.git",
    tag:      "v1.5.2",
    revision: "e6251e1b221a8c78fa6e4ee8440ea1908b5781bf"

  head "https://github.com/zeek/spicy.git",
    branch:  "main"

  bottle do
    root_url "https://github.com/zeek/spicy/releases/download/v1.5.2"
    sha256 monterey: "ea3725fcbd05d47cd864a6c78c43ac966a699d46e90a802a1e9f79c37e18a3d8"
  end

  depends_on "bison" => :build
  depends_on "cmake" => :build
  depends_on "flex" => :build
  depends_on "ccache" => :optional

  def install
    mkdir "build" do
      cmake_args = %W[
        -DBUILD_SHARED_LIBS=ON
        -DCMAKE_C_COMPILER=/usr/bin/clang
        -DCMAKE_CXX_COMPILER=/usr/bin/clang++
        -DFLEX_ROOT=#{Formula["flex"].opt_prefix}
        -DBISON_ROOT=#{Formula["bison"].opt_prefix}
        -DBUILD_TOOLCHAIN=ON
        -DHILTI_DEV_PRECOMPILE_HEADERS=OFF
      ]

      cmake_args << "-DHILTI_COMPILER_LAUNCHER=ccache" if build.with? "ccache"

      system "cmake", "..", *std_cmake_args, *cmake_args
      system "make", "install"
    end
  end

  def caveats
    <<~EOS
      In order to speed up JIT, run 'spicy-precompile-headers' after
      installation. This script places precompiled headers used during
      JIT in '$HOME/.cache/spicy'.

      Per-module JIT results can be cached with ccache which should speed up
      subsequent compilations. For that, set
      'HILTI_CXX_COMPILER_LAUNCHER=ccache' in your environment and make sure
      ccache is installed.
    EOS
  end

  test do
    require "fileutils"
    File.write("foo.spicy", "module Foo; type Bar = unit {};")
    assert_match "module Foo {", shell_output("#{bin}/spicyc -p foo.spicy")
    assert shell_output("#{bin}/spicyc -j foo.spicy")
    assert shell_output("#{bin}/spicy-build foo.spicy")
  end
end
