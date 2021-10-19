class Spicy < Formula
  desc "C++ parser generator for dissecting protocols & files"
  homepage "https://github.com/zeek/spicy"
  url "https://github.com/zeek/spicy.git",
    tag:      "v1.3.0",
    revision: "3872229de57a79b9e150836c6aa2a4678271c363"

  head "https://github.com/zeek/spicy.git",
    branch:  "main"

  bottle do
    root_url "https://github.com/zeek/spicy/releases/download/v1.3.0"
    sha256 catalina: "9e36d27c163bed3811474c3962cba9837641a78a63b1b9278bc779f90e8ab703"
  end
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
      installation. This script places precompiled headers used during
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
