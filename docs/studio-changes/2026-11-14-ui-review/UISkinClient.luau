-- Play와 Edit 미리보기가 같은 이미지·여백 규칙을 사용합니다.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Appearance = require(ReplicatedStorage:WaitForChild("PetMissiles"):WaitForChild("UIAppearance"))
Appearance.Watch(Players.LocalPlayer:WaitForChild("PlayerGui"))
