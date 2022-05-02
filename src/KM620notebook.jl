### A Pluto.jl notebook ###
# v0.19.0

using Markdown
using InteractiveUtils

# ╔═╡ f4747962-bfe6-11ec-1964-eb3e3a043ff2
using DataFrames, Latexify

# ╔═╡ dcfa5d22-5d07-4012-9afa-0f904216e13c
@latexrun ϵ_ts(σ_t, E_y, γ_1, γ_2) = σ_t / E_y + γ_1 + γ_2 # KM-620.1

# ╔═╡ 82845818-9b79-46e8-b74c-661ef5b95c42
@latexrun γ_1(ϵ_1, H) = ϵ_1 / 2 * (1 - tanh(H)) # KM-620.2

# ╔═╡ 69dcf462-6cf8-478d-8386-7432b5ee26e6
@latexrun γ_2(ϵ_2, H) = ϵ_2 / 2 * (1 + tanh(H)) # KM-620.3

# ╔═╡ 9d6d926f-c31f-4c51-a218-f337f444d264
@latexrun ϵ_1(σ_t, A_1, m_1) = (σ_t / A_1)^(1 / m_1) # KM-620.4

# ╔═╡ e5682877-4006-4f93-93f1-adcb11350062
@latexrun A_1(σ_ys, ϵ_ys, m_1) = σ_ys * (1 + ϵ_ys) / (log(1 + ϵ_ys))^m_1 # KM-620.5

# ╔═╡ b7d8375a-b62c-4f87-bb80-5f5172fda25e
@latexrun m_1(R, ϵ_p, ϵ_ys) = (log(R) + (ϵ_p - ϵ_ys)) / log(log(1+ϵ_p)/log(1+ϵ_ys)) # KM-620.6

# ╔═╡ 7449d6ab-605e-4985-8664-d4a38b3683af
@latexrun ϵ_2(σ_t, A_2, m_2) = (σ_t / A_2)^(1 / m_2) # KM-620.7

# ╔═╡ bdbb7aa3-dd44-4245-9142-f625abfc3bc7
@latexrun A_2(σ_uts, m_2) = (σ_uts * exp(m_2)) / (m_2 ^ m_2) # KM-620.8

# ╔═╡ 82c036a0-c340-4a01-9966-d1f78abf45f4
@latexrun H(σ_t, σ_ys, σ_uts, K) = 2 * (σ_t - (σ_ys + K * (σ_uts - σ_ys))) /
												(K * (σ_uts - σ_ys)) # KM-620.9

# ╔═╡ 64fc6f58-c3f3-488a-a362-19bf48a5b4ae
@latexrun R(σ_ys, σ_uts) = σ_ys / σ_uts # KM-620.10

# ╔═╡ dd0d8b1a-2006-4cd4-8c6f-016d27f59b27
@latexrun ϵ_ys() = 0.002 # KM-620.11

# ╔═╡ a742b814-b96a-4e1b-af9a-6c1f90c0460b
@latexrun K(R) = 1.5*R^1.5 - 0.5*R^2.5 - R^3.5 #KM-620.12

# ╔═╡ 99affa24-db6f-4690-add5-be52b5cd2311
@latexrun σ_utst(σ_uts, m_2) = σ_uts * exp(m_2) # KM-620.13

# ╔═╡ 02128e2f-640e-4a7b-9786-01c2a83ac9bb
# Table KM-620 (NOTE: Ferritic steel includes carbon, low alloy, and alloy steels, and ferritic, martensitic, and iron-based age-hardening stainless steels.)
tableKM620 = DataFrame("Material" => ["Ferritic steel",
                                "Austenitic stainless steel and nickel-based alloys",
                                "Duplex stainless steel",
                                "Precipitation hardening, nickel based",
                                "Aluminum",
                                "Copper",
                                "Titanium and zirconium"],
                        "Maximum Temperature (°F)" => [900,
                                                900,
                                                900,
                                                1000,
                                                250,
                                                150,
                                                500],
                        "m₂" => [R -> 0.60 * (1.00 - R),
                                R -> 0.75 * (1.00 - R),
                                R -> 0.70 * (0.95 - R),
                                R -> 1.09 * (0.93 - R),
                                R -> 0.52 * (0.98 - R),
                                R -> 0.50 * (1.00 - R),
                                R -> 0.50 * (0.98 - R)],
                        "m₃" => [(E,l) -> 2*log(1+(E*l/100)),
                                (E,l) -> 3*log(1+(E*l/100)),
                                (E,l) -> 2*log(1+(E*l/100)),
                                (E,l) -> 1*log(1+(E*l/100)),
                                (E,l) -> 1.3*log(1+(E*l/100)),
                                (E,l) -> 2*log(1+(E*l/100)),
                                (E,l) -> 1.3*log(1+(E*l/100))],
                        "m₄" => (R,A) -> log(100 / (100 - R*A)),
                        "m₅" => [2.2,
                                0.6,
                                2.2,
                                2.2,
                                2.2,
                                2.2,
                                2.2],
                        "ϵₚ" => [2.0E-5,
                                2.0E-5,
                                2.0E-5,
                                2.0E-5,
                                5.0E-6,
                                5.0E-6,
                                2.0E-5]
                        )

# ╔═╡ 17109a6c-f2e9-4057-b514-4e6b0ff2f611


# ╔═╡ 8fbd85c1-e7f4-4df5-bfe6-9dc3571a8cf0


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Latexify = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"

[compat]
DataFrames = "~1.3.3"
Latexify = "~0.15.15"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "b153278a25dd42c65abbf4e62344f9d22e59191b"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.43.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "6c19003824cbebd804a51211fd3bbd81bf1ecad5"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.3"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "46a39b9c58749eefb5f2dc1178cb8fab5332b1ab"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.15"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═f4747962-bfe6-11ec-1964-eb3e3a043ff2
# ╠═dcfa5d22-5d07-4012-9afa-0f904216e13c
# ╠═82845818-9b79-46e8-b74c-661ef5b95c42
# ╠═69dcf462-6cf8-478d-8386-7432b5ee26e6
# ╠═9d6d926f-c31f-4c51-a218-f337f444d264
# ╠═e5682877-4006-4f93-93f1-adcb11350062
# ╠═b7d8375a-b62c-4f87-bb80-5f5172fda25e
# ╠═7449d6ab-605e-4985-8664-d4a38b3683af
# ╠═bdbb7aa3-dd44-4245-9142-f625abfc3bc7
# ╠═82c036a0-c340-4a01-9966-d1f78abf45f4
# ╠═64fc6f58-c3f3-488a-a362-19bf48a5b4ae
# ╠═dd0d8b1a-2006-4cd4-8c6f-016d27f59b27
# ╠═a742b814-b96a-4e1b-af9a-6c1f90c0460b
# ╠═99affa24-db6f-4690-add5-be52b5cd2311
# ╠═02128e2f-640e-4a7b-9786-01c2a83ac9bb
# ╠═17109a6c-f2e9-4057-b514-4e6b0ff2f611
# ╠═8fbd85c1-e7f4-4df5-bfe6-9dc3571a8cf0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
