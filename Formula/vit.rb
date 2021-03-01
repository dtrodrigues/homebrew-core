class Vit < Formula
  include Language::Python::Virtualenv

  desc "Full-screen terminal interface for Taskwarrior"
  homepage "https://taskwarrior.org/news/news.20140406.html"
  url "https://files.pythonhosted.org/packages/55/47/6d9a86e0646c0f65bb5be565c05699d11722d42cb2dd71c31380fc52aa73/vit-2.1.0.tar.gz"
  sha256 "fd34f0b827953dfdecdc39f8416d41c50c24576c33a512a047a71c1263eb3e0f"
  license "MIT"
  head "https://github.com/vit-project/vit.git", branch: "2.x"

  bottle do
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "a36d7446ff702acf2b57db04ccbe3f10d32086207d96ad34dc6e013f2a7fdfcf"
    sha256 cellar: :any_skip_relocation, big_sur:       "facc1cfc1cad4655cc045ed25f2f134a2526eb4505a25f4ced073facbed9ebbb"
    sha256 cellar: :any_skip_relocation, catalina:      "be5b88c99d467dcacba5ec84bd12dce9d5196bd5479469d3aaa32744cf531787"
    sha256 cellar: :any_skip_relocation, mojave:        "e1187a8c5a4b75d55bcda3758f1a70375f7cb8fd995239383de172dc408cf23e"
  end

  depends_on "python@3.9"
  depends_on "task"

  resource "pytz" do
    url "https://files.pythonhosted.org/packages/b0/61/eddc6eb2c682ea6fd97a7e1018a6294be80dba08fa28e7a3570148b4612d/pytz-2021.1.tar.gz"
    sha256 "83a4a90894bf38e243cf052c8b58f381bfe9a7a483f6a9cab140bc7f702ac4da"
  end

  resource "tasklib" do
    url "https://files.pythonhosted.org/packages/5e/46/bf8e9aea0f747b89165f9639a0f1e87a65c3295bebae7a01351edba05034/tasklib-2.3.0.tar.gz"
    sha256 "7fe8676acb4559129c4e958be7704c12dccdbae302fff47c5398bc0dd1c9e563"
  end

  resource "tzlocal" do
    url "https://files.pythonhosted.org/packages/ce/73/99e4cc30db6b21cba6c3b3b80cffc472cc5a0feaf79c290f01f1ac460710/tzlocal-2.1.tar.gz"
    sha256 "643c97c5294aedc737780a49d9df30889321cbe1204eac2c2ec6134035a92e44"
  end

  resource "urwid" do
    url "https://files.pythonhosted.org/packages/94/3f/e3010f4a11c08a5690540f7ebd0b0d251cc8a456895b7e49be201f73540c/urwid-2.1.2.tar.gz"
    sha256 "588bee9c1cb208d0906a9f73c613d2bd32c3ed3702012f51efe318a3f2127eae"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    (testpath/".vit").mkpath
    touch testpath/".vit/config.ini"
    touch testpath/".taskrc"

    require "pty"
    PTY.spawn(bin/"vit") do |_stdout, _stdin, pid|
      sleep 3
      Process.kill "TERM", pid
    end
    assert_predicate testpath/".task", :exist?
  end
end
