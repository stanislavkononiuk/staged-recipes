import re

from setuptools import find_namespace_packages, setup


# Ensure we match the version set in src/optimum/version.py
try:
    filepath = "optimum/version.py"
    with open(filepath) as version_file:
        (__version__,) = re.findall('__version__ = "(.*)"', version_file.read())
except Exception as error:
    assert False, "Error: Could not open '%s' due %s\n" % (filepath, error)


REQUIRED_PKGS = [
    "coloredlogs",
    "sympy",
    "transformers>=4.15.0",
    "torch>=1.9",
]

TESTS_REQUIRE = ["pytest"]

QUALITY_REQUIRE = ["black~=22.0", "flake8>=3.8.3", "isort>=5.5.4"]

EXTRAS_REQUIRE = {
    "onnxruntime": ["onnx", "onnxruntime", "datasets>=1.2.1"],
    "intel": [
        "pycocotools",
        "neural_compressor>=1.9",
        "datasets>=1.2.1",
        "pandas<1.4.0",
        "transformers >= 4.15.0, < 4.17.0",
    ],
    "graphcore": "optimum-graphcore",
    "dev": TESTS_REQUIRE + QUALITY_REQUIRE,
    "tests": TESTS_REQUIRE,
    "quality": QUALITY_REQUIRE,
}

setup(
    name="optimum",
    version=__version__,
    description="Optimum Library is an extension of the Hugging Face Transformers library, providing a framework to "
    "integrate third-party libraries from Hardware Partners and interface with their specific "
    "functionality.",
    long_description=open("README.md", "r", encoding="utf-8").read(),
    long_description_content_type="text/markdown",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "License :: OSI Approved :: Apache Software License",
        "Intended Audience :: Developers",
        "Intended Audience :: Education",
        "Intended Audience :: Science/Research",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Topic :: Scientific/Engineering :: Artificial Intelligence",
    ],
    keywords="transformers, quantization, pruning, training, ipu",
    url="https://huggingface.co/hardware",
    author="HuggingFace Inc. Special Ops Team",
    author_email="hardware@huggingface.co",
    license="Apache",
    packages=find_namespace_packages(include=["optimum*"]),
    install_requires=REQUIRED_PKGS,
    extras_require=EXTRAS_REQUIRE,
    # entry_points={
    #     "console_scripts": [
    #         "optimum_export=optimum.onnxruntime.convert:main",
    #         "optimum_optimize=optimum.onnxruntime.optimize_model:main",
    #         "optimum_export_optimize=optimum.onnxruntime.convert_and_optimize:main",
    #     ],
    # },
    include_package_data=True,
    zip_safe=False,
)