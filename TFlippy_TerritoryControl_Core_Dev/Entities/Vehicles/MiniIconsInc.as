//ss
//the frames for the factory/crate icons

namespace FactoryFrame
{
	enum Frame
	{
		unknown = 0,
		longboat = 1,
		warboat = 2,
		mortar = 3,
		catapult = 4,
		ballista = 5,
		mounted_bow = 6,
		steamtank = 7,
		saw = 8,
		drill = 9,
		dinghy = 10,
		gatlinggun = 11,
		howitzer = 12,
		
		military_basics = 13,
		explosives,
		pyro,
		water_ammo,

		boulder = 16,
		expl_ammo,

		factory = 24,
		healing = 25,
		kitchen = 26,
		nursery = 27,
		tunnel = 28,
		storage = 29,

		//end of actual factory/crate icons
		count,

		//hack: these share above icons
		//but are used for scroll frame instead.
		magic_gib = 24,
		magic_midas,
		magic_drought,
		magic_flood,
	};
};
