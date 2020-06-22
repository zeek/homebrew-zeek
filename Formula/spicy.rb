class Spicy < Formula
  desc "C++ parser generator for dissecting protocols & files"
  homepage "https://github.com/zeek/spicy"

  # Do not use a shallow clone since Spicy's `scripts/autogen-version` used
  # during the build requires some Git history.
  head "https://github.com/zeek/spicy.git", :shallow => false

  depends_on "bison" => :build
  depends_on "cmake" => :build
  depends_on "flex" => :build
  depends_on "llvm"
  depends_on "zeek"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args,
                      "-DBUILD_SHARED_LIBS=ON",
                      "-DCMAKE_CXX_COMPILER=#{Formula["llvm"].opt_prefix}/bin/clang++",
                      "-DFLEX_ROOT=#{Formula["flex"].opt_prefix}",
                      "-DBISON_ROOT=#{Formula["bison"].opt_prefix}",
                      "-DLLVM_ROOT=#{Formula["llvm"].opt_prefix}",
                      "-DHILTI_HAVE_JIT=ON"
      system "make", "install"
    end
  end

  test do
    assert_match "clang", shell_output("#{bin}/spicy-config --jit-compiler")

    require "fileutils"
    File.open("foo.spicy", "w") { |f| f.write("module Foo; type Bar = unit {};") }
    assert_match "module Foo {", shell_output("#{bin}/spicyc -p foo.spicy")
    assert shell_output("#{bin}/spicyc -j foo.spicy", 0)
    assert shell_output("#{bin}/spicy-build foo.spicy", 0)
  end
end
