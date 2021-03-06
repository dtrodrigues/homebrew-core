class Cfengine < Formula
  desc "Help manage and understand IT infrastructure"
  homepage "https://cfengine.com/"
  url "https://cfengine-package-repos.s3.amazonaws.com/tarballs/cfengine-3.18.0.tar.gz"
  sha256 "d601a3af30f3fba7d51a37476c9e1a00b750682149bf96f4a0002e804bc87783"

  livecheck do
    url "https://cfengine.com/release-data/community/releases.json"
    regex(/"version": ?"(\d+(?:\.\d+)+)"/i)
  end

  bottle do
    sha256 arm64_big_sur: "3e755d3d93d4f9af8e38a035ae5dc43ee42fd6b5ff11e4dd8d9a42addc193de0"
    sha256 big_sur:       "369f0b971ef4b7968d2e1a8934ce03e4d841b88c9c0a789ca52e8e5d3b619acd"
    sha256 catalina:      "397a614052632c146a1a8668a5e0a1e8ab1569296d6bd94b411b5bf15a61c736"
    sha256 mojave:        "bc4f67e00fa8dc773ab0fcc1b9bb1376513f507fa958bceae50ef943ef5ff670"
  end

  depends_on "lmdb"
  depends_on "openssl@1.1"
  depends_on "pcre"

  resource "masterfiles" do
    url "https://cfengine-package-repos.s3.amazonaws.com/tarballs/cfengine-masterfiles-3.18.0.tar.gz"
    sha256 "968faee4920936739f914b5fcae441cd03354e909bb26c5dcdeb6750f1fde156"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-workdir=#{var}/cfengine",
                          "--with-lmdb=#{Formula["lmdb"].opt_prefix}",
                          "--with-pcre=#{Formula["pcre"].opt_prefix}",
                          "--without-mysql",
                          "--without-postgresql"
    system "make", "install"
    (pkgshare/"CoreBase").install resource("masterfiles")
  end

  test do
    assert_equal "CFEngine Core #{version}", shell_output("#{bin}/cf-agent -V").chomp
  end
end
