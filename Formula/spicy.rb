class Spicy < Formula
  desc "C++ parser generator for dissecting protocols & files"
  homepage "https://github.com/zeek/spicy"
  url "https://github.com/zeek/spicy.git",
    tag:      "v1.2.1",
    revision: "085799df64ccbfdec6e0dd58050f2d98543b19fb"

  head "https://github.com/zeek/spicy.git",
    branch:  "main"

  depends_on "bison" => :build
  depends_on "cmake" => :build
  depends_on "flex" => :build

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args,
                      "-DBUILD_SHARED_LIBS=ON",
                      "-DCMAKE_C_COMPILER=/usr/bin/clang",
                      "-DCMAKE_CXX_COMPILER=/usr/bin/clang++",
                      "-DFLEX_ROOT=#{Formula["flex"].opt_prefix}",
                      "-DBISON_ROOT=#{Formula["bison"].opt_prefix}",
                      "-DBUILD_TOOLCHAIN=ON",
                      "-DHILTI_DEV_PRECOMPILE_HEADERS=OFF",
                      "-DBUILD_ZEEK_PLUGIN=OFF"
      system "make", "install"
    end
  end

  def caveats
    <<~EOS
      In order to speed up JIT, run 'spicy-precompile-headers' after
      installation. This script places precompiled headers using during
      JIT in '$HOME/.cache/spicy'.
    EOS
  end

  test do
    require "fileutils"
    File.open("foo.spicy", "w") { |f| f.write("module Foo; type Bar = unit {};") }
    assert_match "module Foo {", shell_output("#{bin}/spicyc -p foo.spicy")
    assert shell_output("#{bin}/spicyc -j foo.spicy")
    assert shell_output("#{bin}/spicy-build foo.spicy")
  end
end
