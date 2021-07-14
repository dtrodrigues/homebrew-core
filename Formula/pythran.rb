class Pythran < Formula
  include Language::Python::Virtualenv

  desc "Ahead of Time compiler for numeric kernels"
  homepage "https://pythran.readthedocs.io/"
  url "https://files.pythonhosted.org/packages/60/ca/c2bd4b53b33dc87342c96dea7f0cf0b5473f2e39dd38649d8b72b9114316/pythran-0.9.12.tar.gz"
  sha256 "5d50dc74dca1d3f902941865acbae981fc24cceeb9d54673d68d6b5c8c1b0001"
  license "BSD-3-Clause"
  head "https://github.com/serge-sans-paille/pythran.git"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "4056653834555c454541d238ee682662947b616b434cad92de4c6b94af9a8cd8"
    sha256 cellar: :any_skip_relocation, big_sur:       "54adeffab0bcc6785b85521ba761ceee881be84749eaa4463234651dc69ed664"
    sha256 cellar: :any_skip_relocation, catalina:      "54adeffab0bcc6785b85521ba761ceee881be84749eaa4463234651dc69ed664"
    sha256 cellar: :any_skip_relocation, mojave:        "54adeffab0bcc6785b85521ba761ceee881be84749eaa4463234651dc69ed664"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "6d4bf4eeff85441cff9152107312b6f7571e261f756381feb7c002b0f9397873"
  end

  depends_on "gcc" # for OpenMP
  depends_on "numpy"
  depends_on "openblas"
  depends_on "python@3.9"
  depends_on "six"

  resource "beniget" do
    url "https://files.pythonhosted.org/packages/36/09/a4a6a967ca5bcfc0bd6162df4ee93017301fa7d9671483c849300bdba0db/beniget-0.4.0.tar.gz"
    sha256 "72bbd47b1ae93690f5fb2ad3902ce1ae61dcd868ce6cfbf33e9bad71f9ed8749"
  end

  resource "gast" do
    url "https://files.pythonhosted.org/packages/a6/fb/7ff6a4ee66673c5964d3cf515ae85ba2076bc64bc2dcbbbd0153718b005f/gast-0.5.0.tar.gz"
    sha256 "8109cbe7aa0f7bf7e4348379da05b8137ea1f059f073332c3c1cedd57db8541f"
  end

  resource "ply" do
    url "https://files.pythonhosted.org/packages/e5/69/882ee5c9d017149285cab114ebeab373308ef0f874fcdac9beb90e0ac4da/ply-3.11.tar.gz"
    sha256 "00c7c1aaa88358b9c765b6d3000c6eec0ba42abca5351b095321aef446081da3"
  end

  def install
    on_macos do
      gcc_major_ver = Formula["gcc"].any_installed_version.major
      inreplace "pythran/pythran-darwin.cfg" do |s|
        s.gsub!(/^include_dirs=/, "include_dirs=#{Formula["openblas"].opt_include}")
        s.gsub!(/^library_dirs=/, "library_dirs=#{Formula["openblas"].opt_lib}")
        s.gsub!(/^blas=.*/, "blas=openblas")
        s.gsub!(/^CC=.*/, "CC=#{Formula["gcc"].opt_bin}/gcc-#{gcc_major_ver}")
        s.gsub!(/^CXX=.*/, "CXX=#{Formula["gcc"].opt_bin}/g++-#{gcc_major_ver}")
      end
    end

    virtualenv_install_with_resources
  end

  test do
    pythran = Formula["pythran"].opt_bin/"pythran"
    python = Formula["python@3.9"].opt_bin/"python3"

    (testpath/"dprod.py").write <<~EOS
      #pythran export dprod(int list, int list)
      def dprod(arr0, arr1):
        return sum([x*y for x,y in zip(arr0, arr1)])
    EOS
    system pythran, testpath/"dprod.py"
    rm_f testpath/"dprod.py"
    assert_equal "11", shell_output("#{python} -c 'import dprod; print(dprod.dprod([1,2], [3,4]))'").chomp

    (testpath/"arc_distance.py").write <<~EOS
      #pythran export arc_distance(float[], float[], float[], float[])
      import numpy as np
      def arc_distance(theta_1, phi_1, theta_2, phi_2):
        """
        Calculates the pairwise arc distance between all points in vector a and b.
        """
        temp = np.sin((theta_2-theta_1)/2)**2 + np.cos(theta_1)*np.cos(theta_2)*np.sin((phi_2-phi_1)/2)**2
        distance_matrix = 2 * np.arctan2(np.sqrt(temp), np.sqrt(1-temp))
        return distance_matrix
    EOS
    # Test with configured gcc to detect breakages from gcc major versions and for OpenMP support
    with_env(CC: nil, CXX: nil) do
      system pythran, "-DUSE_XSIMD", "-fopenmp", "-march=native", testpath/"arc_distance.py"
    end
    rm_f testpath/"arc_distance.py"
    system python, "-c", <<~EOS
      import numpy as np
      import arc_distance
      d = arc_distance.arc_distance(
        np.array([12.4,0.5,-5.6,12.34,9.21]), np.array([-5.6,3.4,2.3,-23.31,12.6]),
        np.array([3.45,1.5,55.4,567.0,43.2]), np.array([56.1,3.4,1.34,-56.9,-3.4]),
      )
      assert ([1.927, 1., 1.975, 1.83, 1.032] == np.round(d, 3)).all()
    EOS
  end
end
